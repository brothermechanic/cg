# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} )

inherit blender-addon

DESCRIPTION="Blender addon. Mesh editing edges offset."
HOMEPAGE="https://blenderartists.org/t/offset-edges/584283"
EGIT_REPO_URI="https://github.com/helluvamesh/HidesatoIkeya_OffsetEdges"

LICENSE="GPL-2"

src_prepare() {
	default
	mv "${S}/mesh_hidesato_offset_edges.py" "${S}/__init__.py"
}
