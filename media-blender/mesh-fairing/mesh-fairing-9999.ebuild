# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Provides an alternative smoothing operation"
HOMEPAGE="https://github.com/fedackb/mesh-fairing"
EGIT_REPO_URI="https://github.com/fedackb/mesh-fairing"

LICENSE="GPL-3"
RDEPEND="dev-python/scipy"

