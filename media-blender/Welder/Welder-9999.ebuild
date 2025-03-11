# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Generate weld along the edge of intersection of two objects"
HOMEPAGE="https://gumroad.com/l/lQVzQ"
EGIT_REPO_URI="https://github.com/JohnnieWooker/Welder"

LICENSE="GPL-3"

ADDON_SOURCE_SUBDIR=${S}/2.91/${PN}

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/[2,3]D_([A-Z]+_COLOR)/\1/g' -i 2.91/${PN}/utils.py || die "Sed failed"
}
