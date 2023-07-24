# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic toolchain-funcs

DESCRIPTION="Intel Open Path Guiding Library. Algorithms for more efficient ray tracing renderings."
HOMEPAGE="http://www.openpgl.org"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/openpathguidinglibrary/openpgl"
	KEYWORDS="-*"
else
	SRC_URI="https://github.com/openpathguidinglibrary/openpgl/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 ~arm64"
fi

LICENSE="Apache-2.0"
SLOT="0"

X86_CPU_FLAGS=( sse4_2 avx2 avx512dq )
CPU_FLAGS=( cpu_flags_arm_neon ${X86_CPU_FLAGS[@]/#/cpu_flags_x86_} )
IUSE="debug static test tools ${CPU_FLAGS[@]}"
REQUIRED_USE="|| ( ${CPU_FLAGS[@]} )"
RESTRICT="mirror test"

RDEPEND="
	media-libs/embree
	dev-cpp/tbb:=
"

src_configure() {
	use debug && CMAKE_BUILD_TYPE="Debug" || CMAKE_BUILD_TYPE="Release"
	append-flags $(usex debug '-DDEBUG' '-DNDEBUG')
	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use cpu_flags_arm_neon && append-flags -flax-vector-conversions

	local mycmakeargs=(
		-DOPENPGL_BUILD_STATIC=$(usex static)
		-DOPENPGL_ISA_AVX2=$(usex cpu_flags_x86_avx2)
		-DOPENPGL_ISA_AVX512=$(usex cpu_flags_x86_avx512dq)
		-DOPENPGL_ISA_SSE4=$(usex cpu_flags_x86_sse4_2)
		-DOPENPGL_ISA_NEON=$(usex cpu_flags_arm_neon)
		-DOPENPGL_BUILD_TOOLS=$(usex tools)
	)
	cmake_src_configure
}
