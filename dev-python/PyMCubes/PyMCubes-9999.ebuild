EAPI=7

PYTHON_COMPAT=( python{3_7,3_8} )
inherit git-r3 distutils-r1

DESCRIPTION="Marching cubes algorithm to extract iso-surfaces from volumetric data"
HOMEPAGE="https://github.com/pmneila/PyMCubes"

LICENSE="BSD"
SLOT="0"
EGIT_REPO_URI="https://github.com/pmneila/PyMCubes.git"

KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="dev-python/numpy[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"
