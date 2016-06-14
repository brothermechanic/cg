# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. Slideshow with animated cameras"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?360518-Addon-Dynamic-Slideshow"
EGIT_REPO_URI="https://github.com/hapit/blender_addon_dynamic_slideshow.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/dynamic_slideshow.py
	fi
}
