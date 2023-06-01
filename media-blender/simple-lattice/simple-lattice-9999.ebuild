# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Make working with lattices simpler."
HOMEPAGE="https://github.com/BenjaminSauder/SimpleLattice"
EGIT_REPO_URI="https://github.com/BenjaminSauder/SimpleLattice"

LICENSE="GPL-3"

