# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit 

DESCRIPTION="Blender addon. The nodes to create animations."
HOMEPAGE="http://blenderartists.org/forum/showthread.php?350296-Addon-Animation-Nodes"
SRC_URI="https://github.com/JacquesLucke/animation_nodes/releases/download/v2.0/animation_nodes_v2_0_linux.zip"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

S="${WORKDIR}"/animation_nodes

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"
	fi
}
