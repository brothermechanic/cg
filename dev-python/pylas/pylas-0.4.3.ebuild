# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{9..10} )

inherit distutils-r1

DESCRIPTION="Reading Las (lidar) in Python"
HOMEPAGE="https://pypi.org/project/pylas/"
SRC_URI="https://github.com/tmontaigu/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

BDEPEND="
	dev-python/setuptools[${PYTHON_USEDEP}]
"

KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"
LICENSE="BSD"
SLOT="0"

RESTRICT="mirror test"

