# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

PYTHON_COMPAT=( python3_{10..12} )

DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 blender-addon

DESCRIPTION="IsoSurface mesher addon for Blender (Updated by Gogo)"
HOMEPAGE="https://github.com/porkminer/CubeSurfer"
EGIT_REPO_URI="https://github.com/porkminer/CubeSurfer"

LICENSE="GPL-3"

BDEPEND="$(python_gen_cond_dep '
    dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
')"

src_prepare() {
	default
	eapply "${FILESDIR}/${PN}-fix-python-3_11.patch"
}

src_compile() {
	${EPYTHON} setup64.py build_ext --inplace || die "Failed to build mciso.c"
}
