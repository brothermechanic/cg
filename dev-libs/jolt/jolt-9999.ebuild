# Copyright 2023-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="A multi core friendly rigid body physics and collision detection library"
HOMEPAGE="https://github.com/jrouwe/JoltPhysics"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="
		https://github.com/jrouwe/JoltPhysics/archive/refs/tags/v${PV}.tar.gz -> jolt-${PV}.tar.gz
	"
	S="${WORKDIR}/JoltPhysics-${PV}"
	KEYWORDS="~amd64 ~arm64"
else
	EGIT_REPO_URI="https://github.com/jrouwe/JoltPhysics.git"
	inherit git-r3
fi

CMAKE_USE_DIR="${S}/Build"

CPU_FLAGS_X86=(sse4_1 sse4_2 f16c popcnt fma3 avx avx2 avx512f avx512vl)
IUSE="test benchmark debug examples lto viewer wasm
	profiler +renderer +custom-allocator deterministic +double-precision std rtti
	${CPU_FLAGS_X86[@]/#/cpu_flags_x86_}
"

DEPEND="
	viewer? (
		dev-util/DirectXShaderCompiler
	)
"

RESTRICT="!test? ( test )"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DCPP_EXCEPTIONS_ENABLED=$(usex debug)
		-DCPP_RTTI_ENABLED=$(usex rtti)
		-DCROSS_PLATFORM_DETERMINISTIC=$(usex deterministic)
		-DDEBUG_RENDERER_IN_DEBUG_AND_RELEASE=$(usex renderer)
		-DDEBUG_RENDERER_IN_DISTRIBUTION=$(usex renderer)
		-DDISABLE_CUSTOM_ALLOCATOR=$(usex custom-allocator ON OFF)
		-DDOUBLE_PRECISION=$(usex double-precision)
		-DINTERPROCEDURAL_OPTIMIZATION=$(usex lto)
		-DPROFILER_IN_DEBUG_AND_RELEASE=$(usex profiler)
		-DPROFILER_IN_DISTRIBUTION=$(usex profiler)
		-DGENERATE_DEBUG_SYMBOLS=$(usex debug)
		-DUSE_ASSERTS=$(usex debug)
		-DUSE_STD_VECTOR=$(usex std)
		-DUSE_SSE4_1=$(usex cpu_flags_x86_sse4_1)
		-DUSE_SSE4_2=$(usex cpu_flags_x86_sse4_2)
		-DUSE_F16C=$(usex cpu_flags_x86_f16c)
		-DUSE_LZCNT=$(usex cpu_flags_x86_popcnt)
		-DUSE_TZCNT=$(usex cpu_flags_x86_popcnt)
		-DUSE_AVX=$(usex cpu_flags_x86_avx)
		-DUSE_AVX2=$(usex cpu_flags_x86_avx2)
		-DUSE_AVX512=$(usex cpu_flags_x86_avx512f $(usex cpu_flags_x86_avx512vl) OFF)
		-DUSE_FMADD=$(usex cpu_flags_x86_fma3)
		-DJPH_USE_DX12=OFF
		-DJPH_USE_VK=OFF
		-DJPH_USE_MTL=OFF
		-DJPH_SHADER_DEBUG_SYMBOLS=$(usex debug)
		-DTARGET_UNIT_TESTS=$(usex test)
		-DTARGET_HELLO_WORLD=OFF
		-DTARGET_PERFORMANCE_TEST=$(usex benchmark)
		-DTARGET_SAMPLES=$(usex examples)
		-DTARGET_VIEWER=$(usex viewer)
	)

	cmake_src_configure
}

src_test() {
	cd "${BUILD_DIR}"
	./UnitTests || die "tests failed"
}
