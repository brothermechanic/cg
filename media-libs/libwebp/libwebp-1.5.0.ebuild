# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake multilib-minimal

MY_P="${P/_/-}"

DESCRIPTION="A lossy image compression format"
HOMEPAGE="https://developers.google.com/speed/webp/download"
SRC_URI="
	https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${MY_P}.tar.gz
	https://github.com/webmproject/libwebp/archive/v${PV}.tar.gz -> ${MY_P}.tar.gz
"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD"
SLOT="0/7" # subslot = libwebp soname version
if [[ ${PV} != *_rc* ]] ; then
	KEYWORDS="~alpha amd64 arm arm64 hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
fi
IUSE="cpu_flags_arm_neon cpu_flags_x86_sse2 cpu_flags_x86_sse4_1 gif -javascript +jpeg +lossless +png static-libs swap-16bit-csp tiff utils viewer"

REQUIRED_USE="
	javascript? ( !utils )
"

# TODO: dev-lang/swig bindings in swig/ subdirectory
RDEPEND="
	javascript? ( dev-util/emscripten[llvm_targets_WebAssembly(+)] )
	gif? ( media-libs/giflib:= )
	jpeg? ( media-libs/libjpeg-turbo:= )
	viewer? (
		media-libs/freeglut
		virtual/opengl
		media-libs/libsdl2
	)
	png? ( media-libs/libpng:= )
	tiff? ( media-libs/tiff:= )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.2.3-libpng-pkg-config.patch
)

multilib_src_configure() {
	unset EMSCRIPTEN
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DCMAKE_POLICY_DEFAULT_CMP0167="OLD"
		-DCMAKE_FIND_PACKAGE_PREFER_CONFIG="yes"
		-DBUILD_SHARED_LIBS=ON
		-DWEBP_LINK_STATIC="$(usex static-libs)"
		-DWEBP_ENABLE_SIMD="$(usex cpu_flags_x86_sse2)"
		-DWEBP_BUILD_ANIM_UTILS="$(usex utils)"
		-DWEBP_BUILD_CWEBP="$(usex utils)"
		-DWEBP_BUILD_DWEBP="$(usex utils)"
		-DWEBP_BUILD_GIF2WEBP="$(usex gif)"
		-DWEBP_BUILD_IMG2WEBP="$(usex png ON $(usex jpeg ON $(usex tiff)))"
		-DWEBP_BUILD_VWEBP="$(usex viewer)"
		-DWEBP_BUILD_WEBPINFO="$(usex utils)"
		-DWEBP_BUILD_LIBWEBPMUX="ON"
		-DWEBP_BUILD_WEBPMUX="$(usex utils)"
		-DWEBP_BUILD_EXTRAS="$(usex utils)"
		-DWEBP_BUILD_WEBP_JS="$(usex javascript)"
		-DWEBP_BUILD_FUZZTEST="OFF"
		-DWEBP_USE_THREAD="$(usex !javascript)"
		-DWEBP_NEAR_LOSSLESS="$(usex lossless)"
		-DWEBP_ENABLE_SWAP_16BIT_CSP="$(usex swap-16bit-csp)"
	)

	CMAKE_BUILD_TYPE='Release'
	cmake_src_configure
}

multilib_src_install() {
	cmake_src_install
}

multilib_src_install_all() {
	find "${ED}" -type f -name "*.la" -delete || die
	dodoc AUTHORS ChangeLog doc/*.txt NEWS README.md
}
