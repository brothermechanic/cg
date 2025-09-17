# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{0..6} 4_{0..5} 5_0 )

PYTHON_COMPAT=( python3_{11..13} )

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
	echo "{\"Copy Target\" : \"${ED}${CG_BLENDER_SCRIPTS_DIR}/addons/${PN}\"}" > conf.json || die
	${EPYTHON} setup.py build --copy --noversioncheck || die

	blender-addon_src_install
}
