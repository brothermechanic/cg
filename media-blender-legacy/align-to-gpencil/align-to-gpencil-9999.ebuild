# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_{0..1} )

inherit blender-legacy-addon

DESCRIPTION="Blender addon. Align Selection To Gpencil Stroke"
HOMEPAGE="https://blenderartists.org/forum/showthread.php?332160-Addon-Align-Selection-to-Grease-Pencil"
EGIT_REPO_URI="https://github.com/Volantk/blender-legacy-addon-align-to-gpencil"

LICENSE="GPL-2"
