# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-r3

DESCRIPTION="OpenFX. Miscellaneous plugins"
HOMEPAGE="https://github.com/devernay/openfx-misc"
EGIT_REPO_URI="https://github.com/devernay/openfx-misc.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="media-libs/openimageio
	"
RDEPEND="${DEPEND}"

MAKEOPTS="-j1"

src_compile() {
	emake CONFIG=release   || die
}

src_install() {
	INST_DIR="/usr/OFX/Plugins"
	exeinto $INST_DIR/CImg.ofx.bundle/Contents/Linux-x86-64
	doexe ${S}/CImg/Linux-64-release/CImg.ofx.bundle/Contents/Linux-x86-64/CImg.ofx
	exeinto $INST_DIR/Misc.ofx.bundle/Contents/Linux-x86-64
	doexe ${S}/Misc/Linux-64-release/Misc.ofx.bundle/Contents/Linux-x86-64/Misc.ofx
	insinto $INST_DIR/CImg.ofx.bundle/Contents
	doins -r ${S}/CImg/Linux-64-release/CImg.ofx.bundle/Contents/{Info.plist,Resources}
	insinto $INST_DIR/Misc.ofx.bundle/Contents
	doins -r ${S}/Misc/Linux-64-release/Misc.ofx.bundle/Contents/{Info.plist,Resources}
}