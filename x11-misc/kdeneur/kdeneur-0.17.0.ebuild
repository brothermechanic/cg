# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils versionator

DESCRIPTION="GTK+ based GUI for xneur"
HOMEPAGE="http://www.xneur.ru/"
SRC_URI="https://launchpad.net/~andrew-crew-kuznetsov/+archive/xneur-stable/+files/kdeneur_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="nls"

COMMON_DEPEND=">=sys-devel/gettext-0.16.1
	>=x11-misc/xneur-$(get_version_component_range 1-2)
	!x11-misc/xneur[gtk3]
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	dev-qt/qtdbus:5
	kde-base/kdelibs"
RDEPEND="${COMMON_DEPEND}
	nls? ( virtual/libintl )"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	rm -f m4/{lt~obsolete,ltoptions,ltsugar,ltversion,libtool}.m4 \
		ltmain.sh aclocal.m4 || die
	sed -i "s/-Werror -g0//" configure.in || die
	sed -i -e '/Encoding/d' -e '/Categories/s/$/;/' ${PN}.desktop.in || die
	sed -i 's/moc-qt4/moc/g' src/Makefile.* || die
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable nls)
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc AUTHORS ChangeLog NEWS
	doicon pixmaps/kdeneur.png
}

