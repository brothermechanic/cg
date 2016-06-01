# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils git-r3

DESCRIPTION="A cross-platform multimedia framework based on Qt and FFmpeg."
HOMEPAGE="http://qtav.org"
EGIT_REPO_URI="https://github.com/wang-bin/QtAV.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE=""

DEPEND="
	media-video/ffmpeg
	media-libs/openal
	media-libs/libass
	
	dev-util/nvidia-cuda-toolkit
	"

RDEPEND=""

src_configure() {
	myconf=(
		PREFIX=/usr \
	)
	eqmake4 ${myconf[@]} -r QtAV.pro
}
src_install() {
	emake INSTALL_ROOT="${D}" install
}