# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_USE_PEP517=setuptools

inherit distutils-r1

DESCRIPTION="Python Binding of SOLVESPACE Constraint Solver"
HOMEPAGE="https://github.com/realthunder/slvs_py"

EGIT_SUBMODULES=()
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/realthunder/${PN}"
	EGIT_BRANCH="master"
else
	SRC_URI="https://github.com/realthunder/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"
fi


LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

BDEPEND="
	dev-lang/swig
	dev-libs/libpcre
	dev-python/scikit-build[${PYTHON_USEDEP}]
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
