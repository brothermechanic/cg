# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Per-Face Texture Mapping for Production Rendering"
HOMEPAGE="https://ptex.us/"
COMMIT="9b83d751fd1baada7d8ae0085c5a8f5045d94ff7"
SRC_URI="https://github.com/wdas/ptex/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
S=${WORKDIR}/${PN}-${COMMIT}

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~riscv x86"
IUSE="debug doc static-libs"

RDEPEND="virtual/zlib:="
DEPEND="${RDEPEND}"
BDEPEND="doc? ( app-text/doxygen )"

RESTRICT="
	test
	mirror
"

src_prepare() {
	# https://github.com/wdas/ptex/issues/41
	cat <<-EOF > version || die
	v${PV}
	EOF
	cmake_src_prepare
	use elibc_musl && ( sed -e "s/\#if defined(__FreeBSD__)/\#if defined(__clang__)/" -i src/ptex/PtexWriter.cpp || die )
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug 'RelWithDebInfo' 'Release')
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/html"
		-DPTEX_BUILD_STATIC_LIBS=$(usex static-libs)
		-DPTEX_BUILD_DOCS=$(usex doc)
	)
	cmake_src_configure
}
