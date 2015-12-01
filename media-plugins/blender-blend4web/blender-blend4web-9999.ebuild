# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Interactive 3D visualization on the Internet"
HOMEPAGE="https://www.blend4web.com"
EGIT_REPO_URI="https://github.com/TriumphLLC/Blend4Web.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_compile() {
	cd blender_scripts/addons/blend4web
}

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/blender_scripts/addons/blend4web
	fi
}
