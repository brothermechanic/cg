# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools eutils

DESCRIPTION="In-place conversion of text typed in with a wrong keyboard layout (Punto Switcher replacement)"
HOMEPAGE="http://www.xneur.ru/"
SRC_URI="https://launchpad.net/~andrew-crew-kuznetsov/+archive/xneur-stable/+files/xneur_${PV}.orig.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="aplay debug gstreamer gtk gtk3 keylogger libnotify nls openal xosd +spell"

COMMON_DEPEND=">=dev-libs/libpcre-5.0
	sys-libs/zlib
	>=x11-libs/libX11-1.1
	x11-libs/libXtst
	gstreamer? ( >=media-libs/gstreamer-0.10.6 )
	!gstreamer? (
		openal? ( >=media-libs/freealut-1.0.1 )
		!openal? (
			aplay? ( >=media-sound/alsa-utils-1.0.17 ) ) )
	libnotify? (
		gtk? (
			gtk3? ( x11-libs/gtk+:3 )
			!gtk3? ( x11-libs/gtk+:2 ) )
		>=x11-libs/libnotify-0.4.0 )
	spell? ( app-text/enchant )
	xosd? ( x11-libs/xosd )"
RDEPEND="${COMMON_DEPEND}
	gstreamer? ( media-libs/gst-plugins-good
		media-plugins/gst-plugins-alsa )
	nls? ( virtual/libintl )
	gtk3? ( !x11-misc/gxneur )"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

src_prepare() {
	# Fixes error/warning: no newline at end of file
	find -name '*.c' -exec sed -i -e '${/[^ ]/s:$:\n:}' {} + || die
	rm -f m4/{lt~obsolete,ltoptions,ltsugar,ltversion,libtool}.m4 \
		ltmain.sh aclocal.m4 || die

	sed -i -e "s/-Werror -g0//" configure.in || die
	sed -i -e 's/@LDFLAGS@ //' xnconfig.pc.in || die
	eautoreconf
}

src_configure() {
	local myconf

	if use gtk && ! use libnotify; then
		einfo "libnotify is not in USE - gtk USE flag will have no effect"
	fi

	if use gstreamer; then
		elog "Using gstreamer for sound output."
		myconf="--with-sound=gstreamer"
	elif use openal; then
		elog "Using openal for sound output."
		myconf="--with-sound=openal"
	elif use aplay; then
		elog "Using aplay for sound output."
		myconf="--with-sound=aplay"
	else
		elog "Sound support disabled."
		myconf="--with-sound=no"
	fi

	if use gtk; then
		if use gtk3; then
			myconf="${myconf} --with-gtk=gtk3"
		else
			myconf="${myconf} --with-gtk=gtk2"
		fi
	else
		myconf="${myconf} --without-gtk"
	fi

	econf ${myconf} \
		$(use_with debug) \
		$(use_enable nls) \
		$(use_with spell) \
		$(use_with xosd) \
		$(use_with libnotify) \
		$(use_with keylogger)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog README NEWS TODO || die
}

pkg_postinst() {
	elog "This is command line tool. If you are looking for GUI frontend just"
	elog "emerge gxneur, which uses xneur transparently as backend."

	elog
	elog "It is recommended to install dictionary for your language"
	elog "(myspell or aspell), for example app-dicts/aspell-ru."

	ewarn
	ewarn "Note: if xneur became slow, try to comment out AddBind options in config file."
}
