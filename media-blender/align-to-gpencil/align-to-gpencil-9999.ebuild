# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Align Selection To Gpencil Stroke"
HOMEPAGE="https://blenderartists.org/forum/showthread.php?332160-Addon-Align-Selection-to-Grease-Pencil"
EGIT_REPO_URI="https://github.com/Volantk/blender-addon-align-to-gpencil"

LICENSE="GPL-2"
