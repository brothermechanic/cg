# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/slowmovideo/slowmovideo-9999.ebuild,v 1.2 2013/03/04 16:12:45 brothermechanic Exp $

EAPI=5

MY_PN="slowmoVideo"
EGIT_REPO_URI="https://github.com/${MY_PN}/${MY_PN}.git"

inherit cmake-utils eutils git-2

DESCRIPTION="Create slow-motion videos from your footage"
HOMEPAGE="http://slowmovideo.granjow.net/"
SRC_URI=""
LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE="video_cards_nvidia qt4 qt5"

REQUIRED_USE="^^ ( qt4 qt5 )"

# Regarding conditionally disabling qt versions on opencv:
# https://github.com/slowmoVideo/slowmoVideo/issues/41
DEPEND="virtual/ffmpeg
	media-libs/freeglut
	media-libs/glew
	media-libs/libsdl
	qt4? (
		dev-qt/qtopengl:4
		dev-qt/qtscript:4
		dev-qt/qttest:4
		dev-qt/qtxmlpatterns:4
		media-libs/opencv[-qt5]
		)
	qt5? (
		dev-qt/qtopengl:5
		dev-qt/qtscript:5
		dev-qt/qttest:5
		dev-qt/qtxmlpatterns:5
		media-libs/opencv[-qt4]
		)
	virtual/jpeg:*"

RDEPEND="${DEPEND}"
PDEPEND="video_cards_nvidia? ( media-gfx/v3d )"

CMAKE_USE_DIR="${S}/src"

src_configure() {
	if use qt4; then
		mycmakeargs="${mycmakeargs} -DFORCE_QT4=ON"
	fi
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	newicon "${CMAKE_USE_DIR}/${MY_PN}/slowmoUI/res/AppIcon.png" "${PN}.png"
	make_desktop_entry slowmoUI "${MY_PN}"
	make_desktop_entry slowmoFlowEdit "slowmoFlowEditor"
}
