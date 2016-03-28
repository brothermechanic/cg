# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils git-r3

DESCRIPTION="Open Multiple View Geometry library"
HOMEPAGE="http://imagine.enpc.fr/~moulonp/openMVG/"
EGIT_REPO_URI="https://github.com/openMVG/openMVG.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="openmp +build-shared-libs -doc"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:0/16
	dev-cpp/eigen
	sci-libs/cxsparse
	sci-libs/flann[-cuda,static-libs]
	media-libs/jpeg
	sci-libs/lemon
	media-libs/tiff
	sys-libs/zlib
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	epatch "${FILESDIR}"/remove_third_party.patch || die
	rm -r ${S}/src/third_party/{ceres-solver,eigen,cxsparse,flan,jpeg,lemon,png,tiff,zlib}
}

	
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
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_BUILD_TYPE=Release
		-DWITH_SYSTEM_CERES=ON
		"
	cmake-utils_src_configure
}