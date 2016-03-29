# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils git-r3 flag-o-matic

DESCRIPTION="Open Multiple View Geometry library"
HOMEPAGE="http://imagine.enpc.fr/~moulonp/openMVG/"
EGIT_REPO_URI="https://github.com/openMVG/openMVG.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="openmp opencv -shared-libs -doc"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:0/16
	opencv? ( media-libs/opencv:0/3.1[contrib] )
	dev-cpp/eigen:3
	sci-libs/cxsparse
	media-libs/jpeg
	sci-libs/lemon[coin]
	media-libs/tiff
	sys-libs/zlib
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"
PREFIX="/usr"

src_prepare() {
	#cleanup third_party dir
	rm -r ${S}/src/dependencies/osi_clp
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use openmp OpenMVG_USE_OPENMP)
		$(cmake-utils_use doc OpenMVG_BUILD_DOC)
		$(cmake-utils_use shared-libs OpenMVG_BUILD_SHARED)
		$(cmake-utils_use opencv OpenMVG_USE_OPENCV)
		$(cmake-utils_use opencv OpenMVG_USE_OCVSIFT)
		-DOpenMVG_BUILD_TESTS=OFF
		-DOpenMVG_BUILD_EXAMPLES=OFF
		-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF
		-DOpenMVG_BUILD_TESTS=OFF
		-DOpenMVG_USE_INTERNAL_FLANN=ON
		-DEIGEN_INCLUDE_DIR_HINTS="/usr/include/eigen3"
		-DCOINUTILS_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DCLP_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DCLPSOLVER_LIBRARY="/usr/lib/libOsiClp.so" 
		-DOSI_INCLUDE_DIR_HINTS="/usr/include/coin" 
		-DLEMON_INCLUDE_DIR_HINTS="/usr/include" 
		-DLEMON_LIBRARY="/usr/lib/libemon.so"
		"
	cmake-utils_src_configure
}
src_install() {
	unset LDFLAGS
	cmake-utils_src_install
}