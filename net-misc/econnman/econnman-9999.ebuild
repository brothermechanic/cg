# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )

inherit autotools git-r3 python-single-r1

DESCRIPTION="EFL user interface for connman"
HOMEPAGE="http://www.enlightenment.org/"
EGIT_REPO_URI="http://git.enlightenment.org/apps/econnman.git"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND="
	dev-python/python-efl[${PYTHON_USEDEP}]
	net-misc/connman:0"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
