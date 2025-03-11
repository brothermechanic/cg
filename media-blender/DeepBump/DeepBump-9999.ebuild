# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Generates normal & height maps from image textures"
HOMEPAGE="hugotini.github.io/deepbump"
EGIT_REPO_URI="https://github.com/HugoTini/DeepBump"

LICENSE="GPL-3"

RDEPEND="$(python_gen_cond_dep '
	dev-python/numpy[${PYTHON_USEDEP}]
	>=sci-libs/onnxruntime-0.14.0:=[${PYTHON_USEDEP}]
')
"
