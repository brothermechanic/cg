# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PYTHON_COMPAT=( python2_7 python3_6 )

inherit git-r3 cmake-utils python-single-r1


DESCRIPTION="CAD from a parallel universe"
HOMEPAGE="http://www.mattkeeter.com/projects/antimony/3/"
EGIT_REPO_URI="https://github.com/mkeeter/antimony.git"

LICENSE="MIT"

SLOT="0"

KEYWORDS=""

IUSE="python"

DEPEND="
	>dev-util/lemon-3.8.11
	sys-devel/flex
	dev-libs/boost[python]
	media-libs/libpng
	dev-qt/qtcore:5
	python? ( ${PYTHON_DEPS} )
	"
RDEPEND="${DEPEND}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}/gentoo.patch"
	default
}
