# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Blender addon. Simple Mesh Importer for Blender"
HOMEPAGE="https://github.com/BlenderAid/Asset-Flinger"
EGIT_REPO_URI="https://github.com/BlenderAid/Asset-Flinger.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/add_mesh_asset_flinger
	fi
}
