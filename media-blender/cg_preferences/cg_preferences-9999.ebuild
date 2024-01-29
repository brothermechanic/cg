# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{3..6} 4_{0..2} )

inherit blender-addon

DESCRIPTION="Setup CG preferences and hotkeys from JSON config"
HOMEPAGE="https://gitflic.ru/project/brothermechanic/cg_preferences"
EGIT_REPO_URI="https://gitflic.ru/project/brothermechanic/cg_preferences.git"

LICENSE="GPL-3"

