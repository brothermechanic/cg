# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit blender-addon

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

DESCRIPTION="Blender addon. Cork - a powerful standalone boolean calculations software"
HOMEPAGE="https://github.com/dfelinto/cork-on-blender"
EGIT_REPO_URI="https://github.com/brothermechanic/cork-on-blender"

LICENSE="GPL-2"

RDEPEND="
    media-blender/blender-off-addon
    media-gfx/cork
"

