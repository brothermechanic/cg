# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS=cmake
inherit cmake-multilib flag-o-matic

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"

MY_PN="openexr"
MY_P="${MY_PN}-${PV}"
SRC_URI="mirror://githubcl/AcademySoftwareFoundation/${MY_PN}/tar.gz/v${PV} -> ${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/$(ver_cut 1)$(ver_cut 2)" # based on SONAME

KEYWORDS="~amd64 ~arm ~arm64 hppa ~ia64 ~mips ~ppc ~ppc64 sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x86-solaris"

IUSE="large-stack static-libs test"

RESTRICT="!test? ( test )"

BDEPEND="virtual/pkgconfig"

DOCS=( README.md )

MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/IlmBaseConfig.h )

CMAKE_BUILD_TYPE=Release

S="${WORKDIR}/${MY_P}/IlmBase"

src_prepare() {
	if use abi_x86_32; then
		eapply "${FILESDIR}"/${P}-0001-disable-failing-test-on-x86_32.patch
	fi
	sed -i -e "/symlink/d" config/LibraryDefine.cmake || die
	multilib_foreach_abi cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include
		-DCMAKE_INSTALL_LIBDIR=/usr/$(get_libdir)
		-DBUILD_SHARED_LIBS=ON
		-DILMBASE_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DBUILD_TESTING=$(usex test)
		-DILMBASE_INSTALL_PKG_CONFIG=ON
		-DILMBASE_ENABLE_LARGE_STACK=$(usex large-stack)
	)
	multilib_foreach_abi cmake_src_configure
}

