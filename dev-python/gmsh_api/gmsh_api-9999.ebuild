# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_EXT=1

inherit distutils-r1 git-r3

DESCRIPTION="Python Binding of gmsh - API for a great Finite Element Mesher"
HOMEPAGE="https://github.com/lepy/gmsh_api"

EGIT_REPO_URI="https://github.com/lepy/gmsh_api"
EGIT_SUBMODULES=()

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

QA_PRESTRIPPED="usr/lib/python.*/site-packages/${PN}/.*"

RDEPEND="
	>=dev-python/numpy-1.13.1[${PYTHON_USEDEP}]
	>=dev-python/pandas-0.22.0[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"
RESTRICT="
	mirror
	test
"

python_install_all() {
	DOCS=( README.md )
	distutils-r1_python_install_all
}
