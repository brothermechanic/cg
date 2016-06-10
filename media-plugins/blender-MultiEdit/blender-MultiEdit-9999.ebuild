# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon for editing of multiple objects"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?339369-MultiEdit-%28alpha-1%29-Multiple-Objects-Editing!"
EGIT_REPO_URI="https://github.com/antoni4040/MultiEdit-Addon.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=media-gfx/blender-9999"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/MultiEdit_05.py
	fi
}
