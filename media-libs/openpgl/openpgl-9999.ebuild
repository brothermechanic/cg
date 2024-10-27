# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
inherit cmake flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Intel Open Path Guiding Library. Algorithms for more efficient ray tracing renderings."
LICENSE="Apache-2.0 BSD"
HOMEPAGE="http://www.openpgl.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/openpathguidinglibrary/openpgl"
	KEYWORDS="-*"
else
	SRC_URI="https://github.com/openpathguidinglibrary/openpgl/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm64"
fi

SLOT="0/$(ver_cut 1-2 ${PV})"
CPU_FLAGS_X86=(
	sse4_1
	sse4_2
	avx2
	avx512f
	avx512dq
	avx512pf
	avx512vl
)
CPU_FLAGS=(
	"${CPU_FLAGS_X86[@]/#/+cpu_flags_x86_}"
	"cpu_flags_arm_neon cpu_flags_arm64_neon2x"
)

IUSE="debug doc static-libs tbb test tools ${CPU_FLAGS[@]%:*}"
REQUIRED_USE+="
	amd64? ( || ( ${CPU_FLAGS_X86[*]/#/cpu_flags_x86_} ) )
	arm64? ( || ( cpu_flags_arm_neon cpu_flags_arm64_neon2x ) )
	cpu_flags_x86_avx2? (
		cpu_flags_x86_sse4_1
	)
	cpu_flags_x86_avx512f? (
		cpu_flags_x86_avx2
	)
	cpu_flags_x86_avx512vl? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
	)
	cpu_flags_x86_avx512pf? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
	)
	cpu_flags_x86_avx512dq? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
	)
"
RDEPEND="
	media-libs/embree:=
	!tbb? (
		|| (
			sys-devel/gcc[openmp]
			sys-devel/clang-runtime[openmp]
		)
	)
	tbb? (
		>=dev-cpp/tbb-2021
	)
"
DEPEND+="
	${RDEPEND}
"
BDEPEND+="
	>=dev-build/cmake-3.1
"
RESTRICT="mirror test"
S="${WORKDIR}/${PN}-${PV/_/-}"
DOCS=( CHANGELOG.md README.md )

src_configure() {
	CMAKE_BUILD_TYPE=(usex debug "RelWithDebInfo" "Release")

	local mycmakeargs=(
		-DOPENPGL_BUILD_STATIC=$(usex static-libs)
		-DOPENPGL_ISA_NEON=$(usex cpu_flags_arm_neon)
		-DOPENPGL_ISA_NEON2X=$(usex cpu_flags_arm64_neon2x)
		-DOPENPGL_ISA_SSE4=$(usex cpu_flags_x86_sse4_2 "ON" $(usex cpu_flags_x86_sse4_1))
		-DOPENPGL_ISA_AVX2=$(usex cpu_flags_x86_avx2)
		-DOPENPGL_ISA_AVX512=$(usex cpu_flags_x86_avx512f)
		-DOPENPGL_USE_OMP_THREADING=$(usex tbb "OFF" "ON")
		-DOPENPGL_BUILD_TOOLS=$(usex tools)
	)

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use arm64 && append-flags -flax-vector-conversions

	# Disable asserts
	append-cppflags "$(usex debug '' '-DNDEBUG')"

	cmake_src_configure
}
