# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Blender tools for working with edgeloops."
HOMEPAGE="https://blenderartists.org/t/it-is-finally-here-edge-flow-set-flow-for-blender-benjamin-saunder/1128115"
EGIT_REPO_URI="https://github.com/BenjaminSauder/EdgeFlow"

LICENSE="GPL-3"

