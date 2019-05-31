# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Blender addon for offsetting edges"
HOMEPAGE="https://wiki.blender.org/index.php/Extensions:2.6/Py/Scripts/Modeling/offset_edges"
EGIT_REPO_URI="https://github.com/Bombaba/BlenderPythonScripts.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"/mesh_offset_edges.py
	fi
}
