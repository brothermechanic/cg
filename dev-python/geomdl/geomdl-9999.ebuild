EAPI=8

PYTHON_COMPAT=( python3_{9..13} )

DISTUTILS_USE_PEP517=setuptools
inherit distutils-r1

DESCRIPTION="Object-oriented NURBS library in Python"
HOMEPAGE="https://onurraufbingol.com/NURBS-Python/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://github.com/orbingol/NURBS-Python"
	EGIT_BRANCH="5.x"
	KEYWORDS=""
	inherit git-r3
else
	SRC_URI="https://github.com/orbingol/NURBS-Python/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S="${WORKDIR}/NURBS-Python-${PV}"
fi
RESTRICT="mirror"

LICENSE="MIT"
SLOT="0"

BDEPEND="
	dev-python/setuptools-scm[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
	)
"
DEPEND="
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
"
RDEPEND="${DEPEND}"

distutils_enable_tests pytest
distutils_enable_sphinx docs dev-python/sphinx-rtd-theme dev-python/sphinx-autoapi

src_prepare() {
	export SETUPTOOLS_SCM_PRETEND_VERSION=${PV/9999/5\.4\.0}
	printf '%s\n' "${PV}" > VERSION || die

	distutils-r1_src_prepare
}

src_test() {
	local EPYTEST_IGNORE=(
		tests/test_visualization.py
	)
	distutils-r1_src_test
}

pkg_postinst() {
	optfeature "vis" dev-python/matplotlib dev-python/plotly
}
