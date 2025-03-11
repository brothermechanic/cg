# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Convert any mesh to a maze pattern"
HOMEPAGE="https://elfnor.com/mesh-maze-blender-add-on.html"
EGIT_REPO_URI="https://github.com/elfnor/mesh_maze"

LICENSE="MIT"

