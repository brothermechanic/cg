# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..1} )

inherit blender-addon

DESCRIPTION="BlenRig 6 rigging system"
HOMEPAGE="https://github.com/jpbouza/BlenRig"
EGIT_REPO_URI="https://github.com/jpbouza/BlenRig"

LICENSE="GPL-3"

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/[2,3]D_([A-Z]+_COLOR)/\1/g' -i guides/rectangle.py -re 's/[2,3]D_(IMAGE)/\1/g' -i guides/image.py || die "Sed failed"
}
