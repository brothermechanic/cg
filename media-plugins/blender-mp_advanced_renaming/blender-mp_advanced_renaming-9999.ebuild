# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. An advanced functionalities to rename objects"
HOMEPAGE="https://blenderartists.org/forum/showthread.php?408115-Addon-Advanced-Renaming-Panel"
EGIT_REPO_URI="https://github.com/Weisl/mp_advanced_renaming.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/mp_advanced_renaming.py
	fi
}
