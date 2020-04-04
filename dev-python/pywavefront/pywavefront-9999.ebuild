# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )

inherit distutils-r1 git-r3

DESCRIPTION="Python library for importing Wavefront .obj files"
HOMEPAGE="https://github.com/pywavefront/PyWavefront"
EGIT_REPO_URI="https://github.com/pywavefront/PyWavefront.git"

LICENSE="BSD-3-Clause"
SLOT="0"
IUSE=""
KEYWORDS="~amd64"

RDEPEND=""
DEPEND="${REDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
