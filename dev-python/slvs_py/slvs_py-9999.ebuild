# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..10} )

inherit distutils-r1 git-r3

DESCRIPTION="Python Binding of SOLVESPACE Constraint Solver"
HOMEPAGE="https://github.com/realthunder/slvs_py"

EGIT_REPO_URI="https://github.com/realthunder/${PN}"
#EGIT_SUBMODULES=()

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

BDEPEND="
	dev-lang/swig
	dev-libs/libpcre
	dev-python/scikit-build
"
#RDEPEND="
#	=media-gfx/solvespace-2.4.2
#"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"

RESTRICT="
	mirror
	test
"

python_install_all() {
	DOCS=( README.md )
	distutils-r1_python_install_all
}
