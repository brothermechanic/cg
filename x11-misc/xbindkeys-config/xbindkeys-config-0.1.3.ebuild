# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4
inherit eutils toolchain-funcs

DEB_PATCH="${PN}_${PV}-2.diff"
DESCRIPTION="Gtk+ program for configuring xbindkeys"
HOMEPAGE=""
SRC_URI="mirror://debian/pool/main/x/${PN}/${PN}_${PV}.orig.tar.gz
	mirror://debian/pool/main/x/${PN}/${DEB_PATCH}.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

COMMON_DEPEND="dev-libs/glib:2
	x11-libs/gtk+:2
"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
"
RDEPEND="${COMMON_DEPEND}
	x11-misc/xbindkeys
"

S="${WORKDIR}/${P/-/_}"

src_prepare() {
	epatch "${WORKDIR}/${DEB_PATCH}"
	epatch "${FILESDIR}/${P}-build.patch"
	tc-export CC
}

src_install() {
	default
	make_desktop_entry ${PN/-/_} ${PN} preferences-desktop-keyboard \
		'Settings;DesktopSettings;GTK;'
}

pkg_postinst() {
	elog "This application is known to crash when .xbindkeysrc does not exit."
	elog "As a workaround, create this file in your home directory first."
}
