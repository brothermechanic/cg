# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils git-2

DESCRIPTION="Extended properties for Qt5"
HOMEPAGE="https://github.com/lexxmark/QtnProperty"
EGIT_REPO_URI="https://github.com/lexxmark/QtnProperty.git"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	dev-qt/qtcore
	dev-qt/qtgui
	dev-qt/qtwidgets
	dev-qt/qtscript[scripttools]
	sys-devel/flex
	sys-devel/bison"

RDEPEND=""

src_prepare() {
	/usr/lib64/qt5/bin/qmake PREFIX="{D}/usr/" -r
}

src_install() {
	dobin bin-linux/{QtnPEG,QtnPropertyDemo,QtnPropertyTests}
	dolib bin-linux/{libQtnPropertyCore.a,libQtnPropertyWidget.a}
}


