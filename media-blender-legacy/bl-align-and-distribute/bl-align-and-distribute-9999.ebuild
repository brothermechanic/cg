# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{0..6} 4_{0..5} 5_0 )

inherit blender-legacy-addon

DESCRIPTION="Align and distribute tools for blender objects."
HOMEPAGE="https://github.com/Tuily/bl-align-and-distribute"
EGIT_REPO_URI="https://github.com/Tuily/bl-align-and-distribute"

LICENSE="CC0-1.0"

ADDON_SOURCE_SUBDIR=${S}/extension
