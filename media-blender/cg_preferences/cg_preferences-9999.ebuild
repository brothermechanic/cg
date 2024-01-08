# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{3..6} 4_{0..2} )

inherit blender-addon

DESCRIPTION="CG Overlay setup for blender preferences and hotkeys."
HOMEPAGE="https://gitlab.com/brothermechanic/cg_preferences"
EGIT_REPO_URI="https://gitlab.com/brothermechanic/cg_preferences.git"

LICENSE="GPL-3"

