# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Laspy is a python library for reading, modifying and creating LAS LiDAR files"
HOMEPAGE="https://pypi.org/project/laspy/"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/${PN}/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"
fi

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
"

RDEPEND="
	|| (
		>=sci-geosciences/laszip-0.2.1
		dev-python/lazrs[${PYTHON_USEDEP}]
	)
	dev-python/numpy[${PYTHON_USEDEP}]
    dev-python/pyproj[${PYTHON_USEDEP}]
    dev-python/requests[${PYTHON_USEDEP}]
"

LICENSE="BSD"
SLOT="0"

RESTRICT="mirror test"

src_prepare() {
	export SETUPTOOLS_SCM_PRETEND_VERSION=${PV}
	printf '%s\n' "${PV}" > VERSION || die

	distutils-r1_src_prepare
}
