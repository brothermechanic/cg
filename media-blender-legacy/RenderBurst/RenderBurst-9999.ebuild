# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{0..6} 4_{0..5} 5_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Render all cameras, one by one, and store the results"
HOMEPAGE="https://github.com/VertStretch/RenderBurst"
EGIT_REPO_URI="https://github.com/VertStretch/RenderBurst"

LICENSE="MIT"

src_prepare() {
	default
	mv "${S}/RenderBurst41.py" "${S}/__init__.py" || die
}
