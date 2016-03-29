# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils git-r3

DESCRIPTION="3D SFM System"
HOMEPAGE="https://code.google.com/archive/p/libmv/"
EGIT_REPO_URI="https://git.blender.org/libmv.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="+fast +shared-libs -X -test"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:1.2
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	#cleanup third_party dir
	rm -r ${S}/src/third_party/{ceres,eigen,gflags,glog,ldl,colamd,jpeg-7,msinttypes,pthreads-w32,ufconfig,zlib}
	sed \
	-e '/colamd/d' \
	-e '/ADD_SUBDIRECTORY(flann)/,/ADD_SUBDIRECTORY(ssba)/{//!d}' \
	-e '/ADD_SUBDIRECTORY(ssba)/,/IF(WIN32 OR APPLE)/{//!d}' \
	-i ${S}/src/third_party/CMakeLists.txt || die
	#relink headers from third_party dir
	#sed -e 's/png/png12/g' -i ${S}/src/libmv/image/CMakeLists.txt || die
	sed -e "s|png.h|third_party/png/png.h|" -i ${S}/src/libmv/image/image_io.cc || die
	#relink eigen3 headers
	find ${S}/src/libmv -type f -exec sed -i 's/<Eigen\//<eigen3\/Eigen\//g' {} \;
	#relink flann headers
	#find ${S}/src/libmv/correspondence -type f -exec sed -i "s|third_party/flann/src/cpp|flann|g" {} \;
}

	
src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr/local"
		-DCMAKE_BUILD_TYPE=Release
		-DWITH_SYSTEM_CERES=ON
		-DBUILD_GUI=OFF
		$(cmake-utils_use_with fast FAST_DETECTOR)
		$(cmake-utils_use_build shared-libs SHARED)
		$(cmake-utils_use_build test TESTS)
		"
	cmake-utils_src_configure
}