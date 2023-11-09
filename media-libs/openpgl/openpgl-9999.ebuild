# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
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
X86_CPU_FLAGS=(
	sse4_1:sse4_1
	sse4_2:sse4_2
	avx2:avx2
	avx512f:avx512f
	avx512dq:avx512dq
	avx512pf:avx512pf
	avx512vl:avx512vl

)
ARM_CPU_FLAGS=(
	neon:neon
	neon2x:neon2x
)
CPU_FLAGS=(
	${X86_CPU_FLAGS[@]/#/+cpu_flags_x86_}
	${ARM_CPU_FLAGS[@]/#/+cpu_flags_arm_}
)

IUSE="debug doc static-libs tbb test tools ${CPU_FLAGS[@]%:*}"
REQUIRED_USE+="
	|| (
		cpu_flags_arm_neon
		cpu_flags_arm_neon2x
		cpu_flags_x86_sse4_1
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
	)
	tbb
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
	media-libs/embree
	!tbb? (
		|| (
			sys-devel/gcc[openmp]
			sys-devel/clang-runtime[openmp]
		)
	)
	tbb? (
		>=dev-cpp/tbb-2017
	)
"
RDEPEND+="
	${DEPEND}
"
BDEPEND+="
	>=dev-util/cmake-3.1
"
RESTRICT="mirror test"
S="${WORKDIR}/${PN}-${PV/_/-}"
DOCS=( CHANGELOG.md README.md )



src_configure() {
	use debug && CMAKE_BUILD_TYPE="Debug" || CMAKE_BUILD_TYPE="Release"
	# Disable asserts
	append-cppflags $(usex debug '' '-DNDEBUG')
	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use cpu_flags_arm_neon && append-flags -flax-vector-conversions

	local mycmakeargs=(
		-DOPENPGL_BUILD_STATIC=$(usex static-libs)
		-DOPENPGL_ISA_NEON=$(usex cpu_flags_arm_neon)
		-DOPENPGL_ISA_NEON2X=$(usex cpu_flags_arm_neon2x)
		-DOPENPGL_ISA_SSE4=$(usex cpu_flags_x86_sse4_2)
		-DOPENPGL_ISA_SSE4=$(usex cpu_flags_x86_sse4_1)
		-DOPENPGL_ISA_AVX2=$(usex cpu_flags_x86_avx2)
		-DOPENPGL_ISA_AVX512=$(usex cpu_flags_x86_avx512f)
		-DOPENPGL_USE_OMP_THREADING=$(usex tbb "OFF" "ON")
		-DOPENPGL_BUILD_TOOLS=$(usex tools)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	dodoc \
		third-party-programs.txt \
		third-party-programs-Embree.txt \
		third-party-programs-TBB.txt
	einstalldocs
}

