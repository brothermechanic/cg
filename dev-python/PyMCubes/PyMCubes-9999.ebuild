EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
inherit git-r3 distutils-r1

DESCRIPTION="Marching cubes algorithm to extract iso-surfaces from volumetric data"
HOMEPAGE="https://github.com/pmneila/PyMCubes"

LICENSE="BSD"
SLOT="0"
EGIT_REPO_URI="https://github.com/pmneila/PyMCubes"

KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="dev-python/numpy[${PYTHON_USEDEP}]"
BDEPEND="dev-python/cython[${PYTHON_USEDEP}]"

RESTRICT="test mirror"
