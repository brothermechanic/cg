# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

inherit blender-legacy-addon

DESCRIPTION="An open-source Blender addon that converts scenes into interactive, web-accessible 3D viewers."
HOMEPAGE="https://github.com/berloop/blender-web-viewer"
EGIT_REPO_URI="https://github.com/berloop/blender-web-viewer"

LICENSE="MIT"

src_compile() {
	${EPYTHON} setup_files.py || die
}

