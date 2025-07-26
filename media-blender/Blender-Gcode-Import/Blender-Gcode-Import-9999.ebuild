# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

inherit blender-addon

DESCRIPTION="Import GCODE files to Blender"
HOMEPAGE="https://github.com/Heinz-Loepmeier/Blender-Gcode-Import"
EGIT_REPO_URI="https://github.com/Heinz-Loepmeier/Blender-Gcode-Import"

LICENSE="GPL-3"

