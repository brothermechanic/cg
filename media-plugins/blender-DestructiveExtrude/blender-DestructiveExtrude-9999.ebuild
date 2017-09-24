# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. Extrude poligons like in sketchup"
HOMEPAGE="https://github.com/mrachinskiy/blender-addon-booltron"
EGIT_REPO_URI="https://github.com/Darcvizer/Destructive-Extrude.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/DestructiveExtrude.py
	fi
}
