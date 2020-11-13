# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python3_{7..9} )

inherit git-r3 cmake-utils python-single-r1


DESCRIPTION="CAD from a parallel universe"
HOMEPAGE="http://www.mattkeeter.com/projects/antimony/3/"
EGIT_REPO_URI="https://github.com/mkeeter/antimony.git"

LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64"

IUSE=""

DEPEND="
	$(python_gen_cond_dep '
    dev-libs/boost[${PYTHON_MULTI_USEDEP}]
    ')
	dev-util/lemon
	sys-devel/flex
	media-libs/libpng
	dev-qt/qtcore:5
	"
RDEPEND="${DEPEND}"

pkg_setup() {
	python-single-r1_pkg_setup
}
