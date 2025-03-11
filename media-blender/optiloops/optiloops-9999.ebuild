# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Blender addon for optimizing topology."
HOMEPAGE="https://www.blenderkit.com/addons/"
EGIT_REPO_URI="https://github.com/vilemduha/optiloops"

LICENSE="GPL-2"

