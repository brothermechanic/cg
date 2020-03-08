# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="ILM's OpenEXR high dynamic-range image file format libraries"
HOMEPAGE="http://openexr.com/"

SRC_URI="https://github.com/AcademySoftwareFoundation/openexr/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0/24" # based on SONAME

KEYWORDS="amd64"

IUSE="cpu_flags_x86_avx examples static-libs test"

RDEPEND="
	>=media-libs/ilmbase-${PV}:=
	sys-libs/zlib
"

DOCS=( README.md )

S="${WORKDIR}/${P}/OpenEXR"

src_prepare() {
	cmake-utils_src_prepare

	# Fix path for testsuite
	sed -i -e "s:/var/tmp/:${T}:" IlmImfTest/tmpDir.h || die

	sed -i -e "/symlink/d" config/LibraryDefine.cmake || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_INSTALL_INCLUDEDIR=/usr/include
		-DCMAKE_INSTALL_LIBDIR=/usr/$(get_libdir)
		-DOPENEXR_BUILD_BOTH_STATIC_SHARED=$(usex static-libs)
		-DBUILD_TESTING=$(usex test)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
	else
		rm -rf "${ED%/}"/usr/share/doc/${PF}/examples || die
	fi

	into /usr/$(get_libdir)
	dosym libIlmImf-2_4.so		/usr/$(get_libdir)/libIlmImf.so
	dosym libIlmImfUtil-2_4.so	/usr/$(get_libdir)/libIlmImfUtil.so
}
