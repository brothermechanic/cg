# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} )

inherit blender-addon

DESCRIPTION="Addon for quad remeshing, a wrapper for instant meshes"
HOMEPAGE="https://github.com/jayanam/jremesh-tools"
EGIT_REPO_URI="https://github.com/jayanam/jremesh-tools"

LICENSE="GPL-3"

