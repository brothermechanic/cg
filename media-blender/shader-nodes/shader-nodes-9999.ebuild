# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Utilities for Cycles PyNodes"
HOMEPAGE="https://github.com/Secrop/ShaderNodesExtra2.80"
EGIT_REPO_URI="https://github.com/Secrop/ShaderNodesExtra2.80"

LICENSE="GPL-3"

src_install() {
	blender-addon_src_install
	insinto ${GENTOO_BLENDER_ADDONS_DIR}/addons/${PN}/Nodes || die
	doins "${FILESDIR}"/Blur.py
}
