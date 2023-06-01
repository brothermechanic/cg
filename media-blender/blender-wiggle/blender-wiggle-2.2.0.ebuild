# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Simulate spring-like physics on Bone transforms"
HOMEPAGE="https://github.com/shteeve3d/blender-wiggle-2"
EGIT_REPO_URI="https://github.com/shteeve3d/blender-wiggle-2"

LICENSE="GPL-3"

