# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="An open-source generative design framework built on Blender"
HOMEPAGE="https://anton.readthedocs.io/en/latest"
EGIT_REPO_URI="https://github.com/blender-for-science/anton"

LICENSE="GPL-3"

RDEPEND="$(python_gen_cond_dep '
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/gmsh_api[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	sci-libs/scikit-learn[${PYTHON_USEDEP}]
')"

PATCHES=(
	${FILESDIR}/anton-fix-obj-import-export.patch
)
