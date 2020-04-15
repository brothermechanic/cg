 # Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="7"

inherit eutils

DESCRIPTION="Professional review software for VFX, animation, and film production"
HOMEPAGE="https://darbyjohnston.github.io/"
SRC_URI="https://sourceforge.net/projects/djv/files/djv-beta/2.0.5/DJV2_2.0.5_amd64.deb"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
RESTRICT=""
IUSE=""

DEPEND="
	!media-gfx/djv
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
	unpack ./data.tar.gz
}

src_install() {
	
	domenu usr/share/applications/djv.desktop

	insinto /usr/local/
	doins -r usr/local/* || die "doins lib-exe failed"
	exeinto /usr/local/DJV2/bin
	doexe usr/local/DJV2/bin/*
}


