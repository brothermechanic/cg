# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 blender-addon

DESCRIPTION="Blender addon. Camera Calibration using Perspective Views of Rectangles"
HOMEPAGE="https://blenderartists.org/forum/showthread.php?414359-Add-on-Camera-Calibration-using-Perspective-Views-of-Rectangles"
EGIT_REPO_URI="https://github.com/mrossini-ethz/camera-calibration-pvr"
EGIT_BRANCH="blender-2-80"
LICENSE="GPL-2"

RDEPEND="$(python_gen_cond_dep '
    dev-python/setuptools[${PYTHON_USEDEP}]
    dev-python/pycairo[${PYTHON_USEDEP}]
')"

src_compile() {
	cd "${S}"/figures
	${EPYTHON} generate-figures.py
}

