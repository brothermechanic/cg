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

IUSE="+system-ceres +fast +build-shared-libs -X -test -tools"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:1.2
	X? ( media-libs/opencv:0/2.4 )
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	sed -e '/OpenExifJpeg/a \  third_party/png' -i ${S}/src/CMakeLists.txt || die
	sed -e 's/png/png12/g' -i ${S}/src/libmv/image/CMakeLists.txt || die
	sed '/ADD_SUBDIRECTORY(daisy)/a ADD_SUBDIRECTORY(png)' -i ${S}/src/third_party/CMakeLists.txt || die
	sed \
	-e "s|^TARGET.*|TARGET_LINK_LIBRARIES(png12)|" \
	-e 's/INCLUDE/#INCLUDE/g' \
	-e 's/LIBMV/#LIBMV/g' \
	-i ${S}/src/third_party/png/CMakeLists.txt || die	
}

src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_BUILD_TYPE=Release
		$(cmake-utils_use_with system-ceres SYSTEM_CERES)
		$(cmake-utils_use_with fast FAST_DETECTOR)
		$(cmake-utils_use_build X GUI)
		$(cmake-utils_use_build build-shared-libs SHARED)
		$(cmake-utils_use_build tools TOOLS)
		$(cmake-utils_use_build test TESTS)
		"
	cmake-utils_src_configure
}