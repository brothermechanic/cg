# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} )

inherit blender-addon

DESCRIPTION="Blender addon. Make working with lattices simpler."
HOMEPAGE="https://github.com/BenjaminSauder/SimpleLattice"
EGIT_REPO_URI="https://github.com/BenjaminSauder/SimpleLattice"

LICENSE="GPL-3"

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/(bpy.types.VIEW3D_MT_gpencil_edit_context_menu,)/#\1/g' -i __init__.py  || die "Sed failed"
}
