# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{0..6} 4_{0..5} 5_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Adds a Basic Lighting Setup to Your Blender Scene."
HOMEPAGE="https://github.com/don1138/blender-qle"
EGIT_REPO_URI="https://github.com/don1138/blender-qle"

LICENSE="GPL-3"

ADDON_SOURCE_SUBDIR=${S}/quick_lighting_environment/quick_lighting_environment
