# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Photorgammetry (SFM) software"
HOMEPAGE="http://logiciels.ign.fr/?-Micmac,3-"
EGIT_REPO_URI="https://github.com/micmacIGN/micmac.git"

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

src_configure() {
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_POISSON=ON
		-DBUILD_RNX2RTKP=OFF
		-DCUDA_ENABLED=OFF
		-DWITH_CPP11=ON
		-DWITH_OPEN_MP=ON
		-DWITH_CPP11=ON
		-DDEPLOY=ON
		-DNO_X11=OFF
		-DWITH_DOXYGEN=OFF
		-DWITH_OPENCL=$(usex opencl )
		-DWITH_QT5=$(usex qt5 )
	)
	cmake-utils_src_configure
}

