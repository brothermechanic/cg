# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit qmake-utils git-r3

DESCRIPTION="Models Ship hulls using subdivision surfaces."
HOMEPAGE="https://github.com/gpgreen/ShipCAD"
EGIT_REPO_URI="https://github.com/gpgreen/ShipCAD.git"
#EGIT_COMMIT="fe84a80"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-libs/boost
	dev-cpp/eigen"

RDEPEND=""

src_prepare() {
	eapply_user
	myconf=(
		PREFIX=/usr \
		EIGEN_ROOT="/usr/include/eigen3" \
		BOOST_ROOT="/usr" \
	)
	eqmake5 ${myconf[@]} -r ShipCAD.pro
}

