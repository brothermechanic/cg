# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

inherit blender-addon

DESCRIPTION="Calculates minimum, maximum and average viewport FPS"
HOMEPAGE="https://github.com/ScottishCyclops/viewport-fps"
EGIT_REPO_URI="https://github.com/ScottishCyclops/viewport-fps"

LICENSE="GPL-3"

src_prepare() {
	default
	mv "${S}/${PN}.py" "${S}/__init__.py"
}
