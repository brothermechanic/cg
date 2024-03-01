# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..2} )

inherit blender-addon

DESCRIPTION="Non-destructive operations, tools, and generators."
HOMEPAGE="https://hugemenace.gumroad.com/l/nd-blender-addon"
EGIT_REPO_URI="https://github.com/hugemenace/nd"

LICENSE="MIT"

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/[2,3]D_([A-Z]+_COLOR)/\1/g' -i lib/{points,axis}.py || die "Sed failed"
}
