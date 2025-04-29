# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} )

inherit blender-addon

DESCRIPTION="Blender addon for reshaping UV selection into grid."
HOMEPAGE="https://cgcookiemarkets.com/blender/all-products/uv-squares/"
EGIT_REPO_URI="https://github.com/Radivarig/UvSquares"

LICENSE="GPL-2"

