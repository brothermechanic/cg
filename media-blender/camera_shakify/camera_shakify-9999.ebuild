# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Add captured camera shake/wobble to your cameras"
HOMEPAGE="https://github.com/EatTheFuture/camera_shakify"
EGIT_REPO_URI="https://github.com/EatTheFuture/camera_shakify"

LICENSE="GPL-2 CC0-1.0"

