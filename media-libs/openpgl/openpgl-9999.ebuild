# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs

DESCRIPTION="Intel Open Path Guiding Library. Algorithms for more efficient ray tracing renderings."
HOMEPAGE="http://www.openpgl.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/openpathguidinglibrary/openpgl"
else
	SRC_URI="https://github.com/openpathguidinglibrary/openpgl/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm64"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="doc openmp static test tools"

ARM_CPU_FEATURES=(
	cpu_flags_arm_neon:NEON
	cpu_flags_arm_vfpv3:VFPV3
)
X86_CPU_FEATURES_RAW=(
	avx:AVX
	avx2:AVX2
	avx512f:AVX_512F
	f16c:FP16
	fma3:FMA3
	popcnt:POPCNT
	sse:SSE
	sse2:SSE2
	sse3:SSE3
	ssse3:SSSE3
	sse4_1:SSE4_1
	sse4_2:SSE4_2
)

X86_CPU_FEATURES=( ${X86_CPU_FEATURES_RAW[@]/#/cpu_flags_x86_} )
CPU_FEATURES_MAP=(
	${ARM_CPU_FEATURES[@]}
	${X86_CPU_FEATURES[@]}
)
IUSE="${IUSE} ${CPU_FEATURES_MAP[@]%:*}"
RESTRICT="mirror test"

RDEPEND="
	!openmp? ( dev-cpp/tbb )
	media-libs/embree
"

REQUIRED_USE="
	amd64? ( cpu_flags_x86_sse3 )
	arm64? ( cpu_flags_arm_neon )
"

BDEPEND="
	dev-util/cmake
	app-alternatives/lex
	app-alternatives/yacc
"

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	local mycmakeargs=(
		-DOPENPGL_BUILD_STATIC=$(usex static)
		-DOPENPGL_TBB_COMPONENT=$(usex openmp omp tbb)
		-DOPENPGL_ISA_AVX512=$(usex cpu_flags_x86_avx512f)
		-DOPENPGL_ISA_AVX2=$(usex cpu_flags_x86_avx2)
		-DOPENPGL_ISA_NEON=$(usex cpu_flags_arm_neon)
		-DOPENPGL_ISA_SSE4=$(usex cpu_flags_x86_sse4_1)
		-DOPENPGL_BUILD_TOOLS=$(usex tools)
	)
	cmake_src_configure
}

src_compile(){
	cmake_src_compile
}

src_install() {
	cmake_src_install
	use doc && DOCS="doc/*" einstalldocs
}
