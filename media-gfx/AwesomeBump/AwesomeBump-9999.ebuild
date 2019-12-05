# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 eutils qmake-utils

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="http://awesomebump.besaba.com/"
EGIT_REPO_URI="https://github.com/kmkolasinski/AwesomeBump.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS=""

IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtscript:5[scripttools]
	virtual/opengl
	"

RDEPEND="${DEPEND}"

#S="${WORKDIR}/Sources"

src_prepare() {
	cd Sources/utils/QtnProperty
	eqmake5 -r
	cd $S
	eqmake5 
}

src_compile() {
	cd Sources/utils/QtnProperty
	emake || die
	cd $S
	emake || die
}

src_install() {
	INST_DIR="/opt/AwesomeBump"
	insinto $INST_DIR
	doins -r Bin/*
	exeinto $INST_DIR
	find "${S}/workdir" -name 'AwesomeBump' -exec doexe '{}' +
	#doexe workdir/linux-*/AwesomeBump
	dobin "${FILESDIR}/AwesomeBump.sh"
	newicon ${FILESDIR}/logo.png "${PN}".png || die
	make_desktop_entry AwesomeBump.sh
}
