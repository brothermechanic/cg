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

IUSE="+fast +build-shared-libs -X -test"

RDEPEND=">=sci-libs/ceres-solver-1.11
	media-libs/libpng:1.2
	X? ( media-libs/opencv:0/2.4 )
	"

DEPEND="${RDEPEND}"

CMAKE_USE_DIR="${S}/src"

src_prepare() {
	rm -r ${S}/src/third_party/{glog,ldl,colamd}
	sed \
	-e '/gtest/d' \
	-e '/eigen/d' \
	-e '/glog/d' \
	-e '/gflags/d' \
	-i ${S}/src/CMakeLists.txt || die
	sed \
	-e '/colamd/d' \
	-e '/gtest/d' \
	-e '/glog/d' \
	-e '/gflags/d' \
	-e '/ldl/d' \
	-i ${S}/src/third_party/CMakeLists.txt || die
	sed -e 's/png/png12/g' -i ${S}/src/libmv/image/CMakeLists.txt || die
	sed -e "s|#include "png.h"|#include "third_party/png/png.h"|" -i ${S}/src/libmv/image/image_io.cc || die
	sed \
	-e "s|#include <Eigen/Cholesky>|#include <eigen3/Eigen/Cholesky>|" \
	-e "s|#include <Eigen/Core>|#include <eigen3/Eigen/Core>|" \
	-e "s|#include <Eigen/Eigenvalues>|#include <eigen3/Eigen/Eigenvalues>|" \
	-e "s|#include <Eigen/Geometry>|#include <eigen3/Eigen/Geometry>|" \
	-e "s|#include <Eigen/LU>|#include <eigen3/Eigen/LU>|" \
	-e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" \
	-e "s|#include <Eigen/SVD>|#include <eigen3/Eigen/SVD>|" \
	-i ${S}/src/libmv/numeric/numeric.h || die
	sed -e "s|#include <Eigen/Core>|#include <eigen3/Eigen/Core>|" -i ${S}/src/libmv/base/vector.h || die
	sed -e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" -i ${S}/src/libmv/multiview/autocalibration.h || die
	sed \
	-e "s|#include <Eigen/SVD>|#include <eigen3/Eigen/SVD>|" \
	-e "s|#include <Eigen/Geometry>|#include <eigen3/Eigen/Geometry>|" \
	-i ${S}/src/libmv/multiview/euclidean_resection.cc || die
	sed -e "s|#include <Eigen/Core>|#include <eigen3/Eigen/Core>|" -i ${S}/src/libmv/simple_pipeline/camera_intrinsics.h || die
	sed -e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" -i ${S}/src/libmv/multiview/five_point.cc || die
	sed \
	-e "s|#include <Eigen/Geometry>|#include <eigen3/Eigen/Geometry>|" \
	-e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" \
	-i ${S}/src/libmv/multiview/fundamental_parameterization.h || die
	sed -e "s|#include <Eigen/Eigenvalues>|#include <eigen3/Eigen/Eigenvalues>|" -i ${S}/src/libmv/simple_pipeline/keyframe_selection.cc || die
	sed -e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" -i ${S}/src/libmv/detector/mser_detector.cc || die
	sed -e -e "s|#include <Eigen/Core>|#include <eigen3/Eigen/Core>|" -i ${S}/src/libmv/autotrack/quad.h || die
	sed \
	-e "s|#include <Eigen/SVD>|#include <eigen3/Eigen/SVD>|" \
	-e "s|#include <Eigen/QR>|#include <eigen3/Eigen/QR>|" \
	-i ${S}/src/libmv/tracking/track_region.cc || die
}

	
src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_BUILD_TYPE=Release
		-DWITH_SYSTEM_CERES=ON
		-DBUILD_TOOLS=OFF
		$(cmake-utils_use_with system-ceres SYSTEM_CERES)
		$(cmake-utils_use_with fast FAST_DETECTOR)
		$(cmake-utils_use_build X GUI)
		$(cmake-utils_use_build build-shared-libs SHARED)
		$(cmake-utils_use_build tools TOOLS)
		$(cmake-utils_use_build test TESTS)
		"
	cmake-utils_src_configure
}