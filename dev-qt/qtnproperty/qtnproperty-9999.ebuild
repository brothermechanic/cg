# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils git-2

DESCRIPTION="Extended properties for Qt5"
HOMEPAGE="https://github.com/lexxmark/QtnProperty"
EGIT_REPO_URI="https://github.com/lexxmark/QtnProperty.git"

LICENSE="Apache-2"
SLOT="5"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5
	dev-qt/qtscript:5[scripttools]
	sys-devel/flex
	sys-devel/bison"

RDEPEND=""

src_prepare() {
	myconf=(
		PREFIX=/usr \
	)
	eqmake5 ${myconf[@]} -r Property.pro
}

src_install() {
	dobin bin-linux/{QtnPEG,QtnPropertyDemo,QtnPropertyTests}
	dolib bin-linux/{libQtnPropertyCore.a,libQtnPropertyWidget.a}
	insinto /usr/include
	doins -r Core
}


