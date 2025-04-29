# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} )

inherit blender-addon

DESCRIPTION="Blender addon. Utilities for Cycles PyNodes"
HOMEPAGE="https://github.com/Secrop/ShaderNodesExtra2.80"
EGIT_REPO_URI="https://github.com/Secrop/ShaderNodesExtra2.80"

LICENSE="GPL-3"

src_install() {
	blender-addon_src_install
	insinto ${CG_BLENDER_SCRIPTS_DIR}/addons/${PN}/Nodes || die
	doins "${FILESDIR}"/Blur.py
}
