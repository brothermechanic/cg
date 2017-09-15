# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

inherit eutils

MY_PV="12.6.0"

DESCRIPTION="Lightworks is the fastest, most accessible and focused NLE in the industry"
HOMEPAGE="http://www.lwks.com/"
SRC_URI="http://downloads.lwks.com/v14/lwks-14.0.0-amd64.deb"

LICENSE="EditShare"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=""
IUSE=""

RDEPEND="
	dev-libs/glib:2
	dev-libs/atk
	dev-libs/expat
	dev-libs/libffi
	sys-apps/dbus
	virtual/udev
	x11-libs/pango
	x11-libs/gdk-pixbuf
	x11-libs/cairo
	x11-libs/pixman
	x11-libs/gtk+:3
	dev-qt/qtgui:4
	dev-qt/qtcore:4
	media-libs/jpeg:8
	gnome-extra/libgsf
	media-libs/libpng:0
	media-libs/tiff:3
	>=media-libs/freetype-2
	media-libs/fontconfig
	media-libs/glu
	media-libs/mesa
	=media-libs/portaudio-19_pre20140130
	>=media-gfx/nvidia-cg-toolkit-3.1.0013-r2
	x11-libs/libxcb
	x11-libs/libXinerama
	x11-libs/libXrandr
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXrender
	x11-libs/libXfixes
	x11-libs/libICE
	x11-libs/libSM
	x11-libs/libX11
	x11-libs/libXau
	x11-libs/libXdmcp
	x11-libs/libdrm
	app-accessibility/at-spi2-core
"

DEPEND="${RDEPEND}
	!app-arch/deb2targz
	app-arch/unzip
	x11-apps/mkfontdir"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	unpack ./data.tar.xz
}


src_install() {
	exeinto /usr/bin
	doexe usr/bin/lightworks
	domenu usr/share/applications/lightworks.desktop
	doicon usr/share/lightworks/Icons/App.png
	
	insinto /lib/udev/rules.d/
	doins lib/udev/rules.d/20-lightworks.rules
	
	insinto /usr/lib64/${PN}
	doins -r usr/lib/${PN}/* || die "doins lib failed"

	exeinto /usr/lib64/${PN}
	doexe usr/lib/${PN}/spawn || die "doins lib-exe failed"
	doexe usr/lib/${PN}/ntcardvt || die "doins lib-exe failed"

	fperms a+rw "usr/share/lightworks/Preferences"
	fperms a+rw "usr/share/lightworks/Audio Mixes"

	insinto /usr/share/${PN}
	doins -r usr/share/${PN}/* || die "doins share failed"

	insinto /usr/share/fonts
	doins -r usr/share/fonts/* || die "doins fonts failed"
	mkfontdir "${D}/usr/share/fonts/truetype"

	dodoc usr/share/doc/${PN}/*
}


