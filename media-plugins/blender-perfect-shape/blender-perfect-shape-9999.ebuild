# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Shape Extrude Tool"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?389974-Addon-Perfect-Shape-Shape-Extrude-Tool"
EGIT_REPO_URI="https://github.com/hophead-ninja/perfect_shape.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/perfect_shape
	fi
}
