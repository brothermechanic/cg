# Copyright 1999-2022 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..5} )

inherit blender-addon

DESCRIPTION="Blender addon. Works with objects, materials and particle systems."
HOMEPAGE="https://blenderartists.org/t/simple-asset-manager-2-8/1134084"
EGIT_REPO_URI="https://gitlab.com/tibicen/simple-asset-manager"

LICENSE="GPL-2"

