# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

PYTHON_COMPAT=( python3_{10..12} )

DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 blender-addon

DESCRIPTION="Addon for calculating collisions and for creating links between particles"
HOMEPAGE="https://github.com/scorpion81/Blender-Molecular-Script"
EGIT_REPO_URI="https://github.com/scorpion81/Blender-Molecular-Script"

LICENSE="GPL-3"
ADDON_SOURCE_SUBDIR=${S}/molecular

BDEPEND="$(python_gen_cond_dep '
	dev-python/cython[${PYTHON_USEDEP}]
    dev-python/setuptools[${PYTHON_USEDEP}]
')"

src_compile() {
	cd "${S}"/sources
	${EPYTHON} setup.py build_ext --inplace
	cp core.*.so ../molecular || die "Failed to build core.so"
}
