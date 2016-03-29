# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils git-r3

DESCRIPTION="Open Multiple View Geometry library"
HOMEPAGE="http://imagine.enpc.fr/~moulonp/openMVG/"
EGIT_REPO_URI="https://github.com/openMVG/openMVG.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="openmp +build-shared-libs -doc"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:0/16
	dev-cpp/eigen:3
	sci-libs/cxsparse
	sci-libs/flann[-cuda,static-libs]
	media-libs/jpeg
	sci-libs/lemon[coin]
	media-libs/tiff
	sys-libs/zlib
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"
PREFIX="/usr"

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		$(cmake-utils_use openmp OpenMVG_USE_OPENMP)
		$(cmake-utils_use doc OpenMVG_BUILD_DOC)
		$(cmake-utils_use build-shared-libs OpenMVG_BUILD_SHARED)
		-DOpenMVG_USE_OPENCV=OFF
		-DOpenMVG_BUILD_TESTS=OFF
		-DOpenMVG_BUILD_EXAMPLES=OFF
		-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF
		-DOpenMVG_BUILD_TESTS=OFF
		-DEIGEN_INCLUDE_DIR_HINTS="/usr/include/eigen3"
		-DFLANN_INCLUDE_DIR_HINTS="/usr/include" 
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