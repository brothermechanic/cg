# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7} )

inherit distutils-r1 git-r3

DESCRIPTION="Coin3d bindings for Python"
HOMEPAGE="http://pivy.coin3d.org/"
EGIT_REPO_URI="https://github.com/FreeCAD/pivy.git"
#EGIT_COMMIT="a2eab798"

LICENSE="ISC"
SLOT="0"
IUSE=""

RDEPEND="
	media-libs/coin
	media-libs/SoQt
"
DEPEND="
	${RDEPEND}
	dev-lang/swig
"
