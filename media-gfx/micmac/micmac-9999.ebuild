# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils mercurial

DESCRIPTION="Photorgammetry (SFM) software"
HOMEPAGE="http://logiciels.ign.fr/?-Micmac,3-"
EHG_REPO_URI="https://culture3d:culture3d@geoportail.forge.ign.fr/hg/culture3d"
#EHG_REVISION="6772"

LICENSE="CeCILL-B"
SLOT="0"
KEYWORDS="~amd64"
IUSE="qt5 opencl doc"

RDEPEND="
	media-gfx/imagemagick
	sci-libs/proj
	media-gfx/exiv2
	qt5? ( dev-qt/qtcore:5 )
	opencl? ( virtual/opencl )"

DEPEND="${RDEPEND}"

#S="${WORKDIR}/OpenShadingLanguage-Release"

CMAKE_BUILD_TYPE=Release

src_prepare() {
    rm -r {bin,lib}
    epatch "${FILESDIR}"/Apero2Meshlab.patch
    cp "${FILESDIR}"/Apero2Meshlab.c ${S}/src/CBinaires/
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_POISSON=ON
		-DBUILD_RNX2RTKP=OFF
		-DCUDA_ENABLED=OFF
		-DWITH_CPP11=ON
		-DWITH_OPEN_MP=OFF
		-DWITH_CPP11=OFF
		-DNO_X11=OFF
		-DWITH_DOXYGEN=OFF
		$(cmake-utils_use_with opencl OPENCL)
		$(cmake-utils_use_with qt5 QT5)
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
	doexe ${S}/binaire-aux/linux/* #for POISSON and RNX2RTKP)
}
