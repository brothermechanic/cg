# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils git-r3 eutils

DESCRIPTION="Converts images into normal maps"
HOMEPAGE="https://github.com/Theverat/NormalmapGenerator"
EGIT_REPO_URI="https://github.com/Theverat/NormalmapGenerator.git"
#EGIT_BRANCH="3d_preview"

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
	default
	myconf=(
		PREFIX=/usr \
	)
	eqmake5 ${myconf[@]} -r NormalmapGenerator.pro
}

src_install() {
	exeinto /usr/bin/
	doexe NormalmapGenerator
	newicon "${S}"/resources/logo.png "${PN}".png
	make_desktop_entry NormalmapGenerator
}
