# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-r3

DESCRIPTION="OpenFX. Image processing using OpenCV"
HOMEPAGE="https://github.com/devernay/openfx-opencv"
EGIT_REPO_URI="https://github.com/devernay/openfx-opencv.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="media-libs/openimageio
        media-libs/opencv:0/3.1
	"
RDEPEND="${DEPEND}"

src_compile() {
	emake CONFIG=release   || die
}

src_install() {
	INST_DIR="/usr/OFX/Plugins"
	exeinto $INST_DIR/OpenCV.ofx.bundle/Contents/Linux-x86-64
	doexe ${S}/OpenCV/Linux-64-release/OpenCV.ofx.bundle/Contents/Linux-x86-64/OpenCV.ofx
	insinto $INST_DIR/OpenCV.ofx.bundle/Contents/
	doins -r ${S}/OpenCV/Linux-64-release/OpenCV.ofx.bundle/Contents/Info.plist
}
