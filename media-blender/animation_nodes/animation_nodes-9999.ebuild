# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

PYTHON_COMPAT=( python3_{10..12} )

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
inherit distutils-r1 blender-addon

DESCRIPTION="Blender addon. Node based visual scripting system designed for motion graphics in Blender."
HOMEPAGE="https://github.com/JacquesLucke/animation_nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/${PN}"

LICENSE="GPL-2"

RDEPEND="$(python_gen_cond_dep 'dev-python/numpy[${PYTHON_USEDEP}]')"

ADDON_SOURCE_SUBDIR=${S}/${PN}

src_install(){
	echo "{\"Copy Target\" : \"${ED}${GENTOO_BLENDER_ADDONS_DIR}/${PN}\"}" > conf.json
	esetup.py build --copy --noversioncheck

	blender-addon_src_install
}
