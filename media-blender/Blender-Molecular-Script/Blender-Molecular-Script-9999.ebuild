# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517="no"
DISTUTILS_EXT=1

inherit distutils-r1 blender-addon

DESCRIPTION="Addon for calculating collisions and for creating links between particles"
HOMEPAGE="https://github.com/scorpion81/Blender-Molecular-Script"
EGIT_REPO_URI="https://github.com/scorpion81/Blender-Molecular-Script"

LICENSE="GPL-3"
ADDON_SOURCE_SUBDIR=${S}/molecular

BDEPEND="$(python_gen_cond_dep '
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
')"

src_prepare() {
	default
	sed -e "s/-O3/${CFLAGS// /\', \'}/g" \
		-i "${S}/sources/setup.py" || die
	distutils-r1_python_prepare_all
}
src_compile() {
	cd "${S}"/sources
	${EPYTHON} setup.py build_ext --inplace || die
 	for lib in *.cpython-*.so ; do
         local base=${lib##*/}
         ln -s "${base}" "${base%%.*}.so" || die
    done
	cp -P core*.so ../molecular || die "Failed to build core.so"
	cp core.pyx ../molecular || die
}
