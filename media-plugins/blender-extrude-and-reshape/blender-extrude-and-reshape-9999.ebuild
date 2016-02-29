# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Extrude and Reshape"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?376618-Addon-Push-Pull-Face"
EGIT_REPO_URI="https://github.com/Mano-Wii/Addon-Push-Pull-Face.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/mesh_extrude_and_reshape.py
	fi
}
