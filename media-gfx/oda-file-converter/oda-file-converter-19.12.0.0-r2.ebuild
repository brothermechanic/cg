# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils multilib

DESCRIPTION="Converts files between the .dwg and .dxf file formats"
HOMEPAGE="http://www.opendesign.com/guestfiles"

URL_64="https://download.opendesign.com/guestfiles/ODAFileConverter/ODAFileConverter_QT5_lnxX64_4.7dll.deb"
URL_32="https://download.opendesign.com/guestfiles/ODAFileConverter/ODAFileConverter_QT5_lnxX86_4.7dll.deb"

SRC_URI="
	amd64? ( ${URL_64} )
	x86? ( ${URL_32} )
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="mirror"

DEPEND="
	dev-qt/qtcore
	x11-themes/hicolor-icon-theme
"

RDEPEND="${DEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack $A
	unpack ./data.tar.gz
	cd ./usr
}

src_install() {
	exeinto /usr/bin
	doexe usr/bin/ODAFileConverter
	ODAFileConverter_19.12.0.0
	exeinto /usr/bin/ODAFileConverter_19.12.0.0
	doexe usr/bin/ODAFileConverter_19.12.0.0/*
	domenu usr/share/applications/ODAFileConverter_19.12.0.0.desktop
	doicon -s 16 usr/share/icons/hicolor/16x16/apps/ODAFileConverter.png
	doicon -s 32 usr/share/icons/hicolor/32x32/apps/ODAFileConverter.png
	doicon -s 64 usr/share/icons/hicolor/64x64/apps/ODAFileConverter.png
	doicon -s 128 usr/share/icons/hicolor/128x128/apps/ODAFileConverter.png
}
