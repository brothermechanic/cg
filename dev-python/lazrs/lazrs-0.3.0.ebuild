# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{8..10} )

inherit distutils-r1

MY_PN="laz-rs-python"
DESCRIPTION="Python bindings for the laz-rs crate."
HOMEPAGE="https://pypi.org/project/lazrs"
SRC_URI="https://github.com/tmontaigu/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"

BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/setuptools_scm[${PYTHON_USEDEP}]
"

RESTRICT="mirror"

S=${WORKDIR}/${MY_PN}-${PV}
