# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-r3

DESCRIPTION="OpenFX. The Readers/Writers plugins"
HOMEPAGE="https://github.com/MrKepzie/openfx-io"
EGIT_REPO_URI="https://github.com/MrKepzie/openfx-io.git"
EGIT_COMMIT="4ddf4a5"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="media-libs/SeExpr
	media-libs/openexr
	media-video/ffmpeg
	media-libs/openimageio
	media-libs/opencolorio
	"
RDEPEND="${DEPEND}"

src_compile() {
	emake CONFIG=release   || die
}

src_install() {
	INST_DIR="/usr/OFX/Plugins"
	exeinto $INST_DIR/IO.ofx.bundle/Contents/Linux-x86-64
	doexe ${S}/IO/Linux-64-release/IO.ofx.bundle/Contents/Linux-x86-64/IO.ofx
	insinto $INST_DIR/IO.ofx.bundle/Contents
	doins -r ${S}/IO/Linux-64-release/IO.ofx.bundle/Contents/{Info.plist,Resources}
}