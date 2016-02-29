# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. Shape Extrude Tool"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?315980-v1-1-1-Archimesh-Architecture-elements-(rooms-doors-columns-stairs-tile-roofs)"
EGIT_REPO_URI="https://github.com/Antonioya/blender.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_install() {
	mv "${S}"/archimesh/src "${S}"/archimesh/archimesh
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/archimesh/archimesh
	fi
}
