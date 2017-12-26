# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="PureRef - Reference Image Viewer"
HOMEPAGE="https://www.pureref.com"
SRC_URI="http://openartisthq.org/debian/xenial64/PureRef-1.9.2_x64.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}"

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
