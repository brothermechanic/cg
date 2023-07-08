# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1

DESCRIPTION="An ntegrating Python development in Emacs. Python lib"
HOMEPAGE="http://github.com/jorgenschaefer/elpy"
SRC_URI="https://github.com/jorgenschaefer/elpy/archive/${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="amd64 x86"
LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	dev-python/coverage
	dev-python/jedi
	dev-python/mock
	dev-python/virtualenv
	dev-python/nose
"

RESTRICT="test mirror"
