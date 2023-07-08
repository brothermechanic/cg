# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Python library for working with 3D point clouds."
HOMEPAGE="https://pypi.org/project/pyntcloud/"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/daavoo/pyntcloud"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/daavoo/pyntcloud/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"
fi

IUSE="plot numba las"
LICENSE="MIT"
SLOT="0"

BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"
RDEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	>=dev-python/scipy-1.6.0[${PYTHON_USEDEP}]
	dev-python/pandas[${PYTHON_USEDEP}]
	las? (
		dev-python/laspy[${PYTHON_USEDEP}]
		dev-python/lazrs[${PYTHON_USEDEP}]
	)
	plot? (
		dev-python/ipython[${PYTHON_USEDEP}]
		dev-python/matplotlib[${PYTHON_USEDEP}]
	)
	numba? ( dev-python/numba[${PYTHON_USEDEP}] )
"

RESTRICT="mirror test"
