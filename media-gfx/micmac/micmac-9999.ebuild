# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils mercurial

DESCRIPTION="Photorgammetry (SFM) software"
HOMEPAGE="http://logiciels.ign.fr/?-Micmac,3-"
EHG_REPO_URI="https://culture3d:culture3d@geoportail.forge.ign.fr/hg/culture3d"

LICENSE="CeCILL-B"
SLOT="0"
KEYWORDS="~amd64"
IUSE="qt5 -openmp opencl"
#TODO failed build with openmp
RDEPEND="
	media-gfx/imagemagick
	sci-libs/proj
	media-gfx/exiv2
	qt5? ( dev-qt/qtcore:5 )
	opencl? ( virtual/opencl )
	openmp? ( sys-devel/gcc[openmp] )"

DEPEND="${RDEPEND}"

#S="${WORKDIR}/OpenShadingLanguage-Release"

CMAKE_BUILD_TYPE=Release

src_prepare() {
    rm -r {bin,lib}


src_configure() {
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		-DBUILD_PATH_BIN="/usr/bin"
		-DBUILD_PATH_LIB="/usr/lib"
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DBUILD_POISSON=OFF
		-DBUILD_RNX2RTKP=ON
		-DCUDA_ENABLED=OFF
		-DNO_X11=OFF
		-DWITH_DOXYGEN=OFF
		$(cmake-utils_use_with opencl OPENCL)
		$(cmake-utils_use_with openmp OPEN_MP)
		$(cmake-utils_use_with qt5 QT5)
	)
	cmake-utils_src_configure
}

src_install() {
	dobin -r bin/*
	dobin -r binaire-aux/linux/*
	dolib -r lib/*
}
