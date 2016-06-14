# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Tools for mesh trimming"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?383334-Polyline-Cut-Mesh-by-patmo141"
EGIT_REPO_URI="https://github.com/patmo141/cut_mesh.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"
	fi
}
