# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Use Deshaker data in Blender to stabilize video!"
HOMEPAGE="http://blog.sergem.net/video-stabilization-with-deshaker-in-blender/"
EGIT_REPO_URI="https://github.com/sergem155/blender-deshaker-log-import.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/import_deshaker_damper.py
	fi
}
