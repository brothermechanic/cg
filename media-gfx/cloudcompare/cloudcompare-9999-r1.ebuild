# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils eutils

DESCRIPTION="3D point cloud processing software"
HOMEPAGE="http://www.danielgm.net/cc/"
EGIT_REPO_URI="https://github.com/cloudcompare/trunk"
EGIT_BRANCH="master"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="media-libs/glew
	sci-mathematics/cgal
	sci-libs/pcl
	dev-qt/qtcore:5
	dev-qt/qtopengl:5"

RDEPEND="${DEPEND}"


src_configure() {
	local mycmakeargs=""
	mycmakeargs=(
	"${mycmakeargs}"
	-DCMAKE_INSTALL_PREFIX="/usr"
    -DINSTALL_QPCL_PLUGIN=ON
    -DINSTALL_QSRA_PLUGIN=OFF
    -DINSTALL_QPOISSON_RECON_PLUGIN=OFF
    -DINSTALL_QHPR_PLUGIN=OFF
    -DINSTALL_QRANSAC_SD_PLUGIN=OFF
    -DINSTALL_QKINECT_PLUGIN=OFF
    -DINSTALL_QBLUR_PLUGIN=OFF
    -DINSTALL_QPCV_PLUGIN=OFF
    -DINSTALL_QDUMMY_PLUGIN=OFF 
	-DINSTALL_QSSAO_PLUGIN=ON
	-DINSTALL_QEDL_PLUGIN=ON
	-DCOMPILE_CC_CORE_LIB_WITH_CGAL=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newicon "${S}"/qCC/images/icon/cc_icon_64.png "${PN}".png
	make_desktop_entry CloudCompare
}
