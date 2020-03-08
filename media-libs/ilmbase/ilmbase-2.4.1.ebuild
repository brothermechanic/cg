# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"

MY_PN="openexr"
MY_P="${MY_PN}-${PV}"
SRC_URI="mirror://githubcl/AcademySoftwareFoundation/${MY_PN}/tar.gz/v${PV} -> ${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0/24" # based on SONAME

KEYWORDS="amd64"

IUSE="static-libs test"

DOCS=( README.md )

S="${WORKDIR}/${MY_P}/IlmBase"

src_prepare() {
	cmake-utils_src_prepare
	sed -i -e "/symlink/d" config/LibraryDefine.cmake || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include
		-DCMAKE_INSTALL_LIBDIR=/usr/$(get_libdir)
		-DBUILD_SHARED_LIBS=ON
		-DILMBASE_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DBUILD_TESTING=$(usex test)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	into /usr/$(get_libdir)
	dosym libHalf-2_4.so		/usr/$(get_libdir)/libHalf.so
	dosym libIex-2_4.so		/usr/$(get_libdir)/libIex.so
	dosym libIexMath-2_4.so		/usr/$(get_libdir)/libIexMath.so
	dosym libIlmThread-2_4.so	/usr/$(get_libdir)/libIlmThread.so
	dosym libImath-2_4.so		/usr/$(get_libdir)/libImath.so
}
