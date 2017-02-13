# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. For auto mirror modifier"
HOMEPAGE="https://blenderaddonlist.blogspot.ru/2014/07/addon-auto-mirror.html"
EGIT_REPO_URI="https://github.com/lapineige/Blender_add-ons.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/AutoMirror/AutoMirror_V2-4.py
	fi
}
