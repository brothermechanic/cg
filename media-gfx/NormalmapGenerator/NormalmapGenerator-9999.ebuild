# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils git-r3

DESCRIPTION="A simple program that converts images into normal maps"
HOMEPAGE="https://github.com/Theverat/NormalmapGenerator"
EGIT_REPO_URI="https://github.com/Theverat/NormalmapGenerator.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtwidgets:5"

RDEPEND=""

src_prepare() {
	myconf=(
		PREFIX=/usr \
	)
	eqmake5 ${myconf[@]} -r NormalmapGenerator.pro
}
