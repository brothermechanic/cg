# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Set the Viewport Color based on a nodetree"
HOMEPAGE="https://github.com/johnnygizmo/set_viewport_color"
EGIT_REPO_URI="https://github.com/johnnygizmo/set_viewport_color"

LICENSE="MIT"

RDEPEND="
        media-blender/blender-off-addon
        media-gfx/cork"

