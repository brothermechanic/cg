# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{3..6} 4_{0..5} 5_0 )

inherit blender-legacy-addon

DESCRIPTION="Setup CG preferences and hotkeys from JSON config"
HOMEPAGE="https://gitflic.ru/project/brothermechanic/cg_preferences"
EGIT_REPO_URI="https://gitflic.ru/project/brothermechanic/cg_preferences.git"

LICENSE="GPL-3"

ADDON_SOURCE_SUBDIR=${S}/${PN}
