# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit eutils

DESCRIPTION="LionRender sync client"
HOMEPAGE="http://lionrender.com"
SRC_URI="http://liondist.s3.amazonaws.com/lionsync-latest-amd64.deb"

LICENSE="TheClarifiedArtisticLicense"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	"

RDEPEND="
	dev-lang/python:2.7
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtxmlpatterns:4
	dev-libs/openssl
	dev-libs/libevent
	"

S="${WORKDIR}"

src_unpack() {
	unpack $A
	unpack ./data.tar.xz
}

src_install() {
	dobin usr/bin/* || die
	dolib usr/lib/*.so* || die
	insinto /usr/lib/python2.7/dist-packages
	doins -r usr/lib/python2.7/dist-packages/* || die
	domenu usr/share/applications/lionsync.desktop
	doicon -s 16 usr/share/icons/hicolor/16x16/apps/lionsync.png
	doicon -s 32 usr/share/icons/hicolor/32x32/apps/lionsync.png
	doicon -s 48 usr/share/icons/hicolor/48x48/apps/lionsync.png
	doicon -s 64 usr/share/icons/hicolor/64x64/apps/lionsync.png
	insinto /usr/share
	doins -r usr/share/{man,pixmaps}
}
