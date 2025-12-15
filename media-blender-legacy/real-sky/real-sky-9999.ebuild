# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

inherit blender-legacy-addon

DESCRIPTION="Physical sky lighting and 3D procedural clouds"
HOMEPAGE="https://gitlab.com/marcopavanello/real-sky"
EGIT_REPO_URI="https://gitlab.com/marcopavanello/real-sky"

LICENSE="GPL-3"

