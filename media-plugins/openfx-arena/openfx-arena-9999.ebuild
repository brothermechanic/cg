# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-r3

DESCRIPTION="OpenFX. A set of visual effect plugins for OpenFX"
HOMEPAGE="https://github.com/MrKepzie/openfx-arena"
EGIT_REPO_URI="https://github.com/MrKepzie/openfx-arena.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-libs/libzip
	media-libs/freetype
	media-libs/fontconfig
	media-libs/libpng
	dev-libs/libxml2
	media-libs/lcms
	x11-libs/pango
	media-libs/openimageio
	media-gfx/imagemagick
	"
RDEPEND="${DEPEND}"

src_compile() {
	emake CONFIG=release   || die
}

src_install() {
	INST_DIR="/usr/OFX/Plugins"
	exeinto $INST_DIR/Arena.ofx.bundle/Contents/Linux-x86-64
	doexe ${S}/Bundle/Linux-64-release/Arena.ofx.bundle/Contents/Linux-x86-64/Arena.ofx
	insinto $INST_DIR/Arena.ofx.bundle/Contents
	doins -r ${S}/Bundle/Linux-64-release/Arena.ofx.bundle/Contents/{Info.plist,Resources}
}