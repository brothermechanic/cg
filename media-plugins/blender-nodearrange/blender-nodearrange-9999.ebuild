# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Cleaning up Node Trees"
HOMEPAGE="http://www.blendernation.com/2015/11/03/development-cleaning-up-node-trees/"
EGIT_REPO_URI="https://github.com/JuhaW/NodeArrange.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/*
	fi
}
