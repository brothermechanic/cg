# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_{0..1} )

inherit blender-legacy-addon

DESCRIPTION="Blender addon for easiest, fastest and most advanced lighting setup."
HOMEPAGE="https://blendermarket.com/products/leomoon-lightstudio"
EGIT_REPO_URI="https://github.com/leomoon-studios/leomoon-lightstudio"

LICENSE="GPL-2"

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && ( sed -re 's/[2,3]D_([A-Z]+_COLOR)/\1/g' -i operators/modal_utils.py || die "Sed failed" )
}
