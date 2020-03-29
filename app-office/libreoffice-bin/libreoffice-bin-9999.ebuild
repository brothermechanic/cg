# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="A full office productivity suite. Binary package"
HOMEPAGE="https://www.libreoffice.org"
SRC_URI="https://libreoffice.soluzioniopen.com/stable/standard/LibreOffice-fresh.standard-x86_64.AppImage"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	!app-office/libreoffice
"
RDEPEND="${DEPEND}"

S=${DISTDIR}

src_install() {
	newbin LibreOffice-fresh.standard-x86_64.AppImage ${PN}
	newicon ${FILESDIR}/*.png ${PN}.png
	make_desktop_entry ${PN} LibreOffice
}
