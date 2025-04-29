# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} )

inherit blender-addon

DESCRIPTION="Adds a deformation rig for vehicules, generates animation rig and bake wheels animation."
HOMEPAGE="https://github.com/digicreatures/rigacar"
EGIT_REPO_URI="https://github.com/digicreatures/rigacar"

LICENSE="GPL-3"
