# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

DESCRIPTION="PureRef - Reference Image Viewer"
HOMEPAGE="https://www.pureref.com"
SRC_URI="${P}_x64.deb"
RESTRICT="fetch strip"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="sys-fs/fuse:0"

S="${WORKDIR}"

pkg_nofetch() {
	einfo "Please download ${P}_x64.deb and move it to"
	einfo "your distfiles directory:"
	einfo "https://www.pureref.com/download.php"
	einfo
}

src_unpack() {
	unpack ${A}
	unpack ./data.tar.xz
}

src_install() {
	exeinto /usr/bin
	doexe ${S}/usr/bin/PureRef
	domenu ${S}/usr/share/applications/pureref.desktop
	doicon ${S}/usr/share/icons/hicolor/128x128/apps/pureref.png
}

pkg_postinst() {
        xdg_desktop_database_update
}
