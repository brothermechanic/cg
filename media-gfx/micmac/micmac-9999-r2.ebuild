# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils eutils git-r3

DESCRIPTION="Photorgammetry (SFM) software"
HOMEPAGE="http://logiciels.ign.fr/?-Micmac,3-"
EGIT_REPO_URI="https://github.com/micmacIGN/micmac.git"

LICENSE="CeCILL-B"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+qt5 opencl -doc"

RDEPEND="
	media-gfx/imagemagick
	sci-libs/proj
	media-gfx/exiv2
	qt5? ( dev-qt/qtcore:5 )
	opencl? ( virtual/opencl )"

DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_prepare() {
    default
    rm -r binaire-aux
    cp "${FILESDIR}"/Apero2Meshlab.c src/CBinaires/ || die
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_PATH_BIN="/usr"
		-DBUILD_PATH_LIB="/usr/lib"
		-DBUILD_POISSON=OFF
		-DBUILD_RNX2RTKP=ON
		-DCUDA_ENABLED=OFF
		-DWITH_CPP11=ON
		-DWITH_OPEN_MP=OFF
		-DWITH_CPP11=OFF
		-DWITH_DOXYGEN=OFF
		-DCUDA_ENABLED=OFF
		-DWITH_OPENCL=$(usex opencl)
		-DWITH_QT5=$(usex qt5)
	)
	cmake-utils_src_configure
}

src_install() {
	#i can't find more elegant install way
	cd  ${BUILD_DIR}
	make install
	insinto /usr
	doins -r ${S}/{lib,data,include}
	if use doc; then
		doins -r ${S}/Documentation
	fi
	exeinto /usr/bin
	doexe ${S}/bin/*
	doexe ${S}/binaire-aux/linux/*
	#doexe ${S}/binaire-aux/linux/* #for POISSON and RNX2RTKP)
}
