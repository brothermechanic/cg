# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/AwesomeBump/AwesomeBump-9999.ebuild,v 1.1 2015-03-27 13:19:13 brothermechanic Exp $

#TODO create menu launcher

EAPI=5

inherit git-2 eutils

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

src_unpack(){
	git-2_src_unpack
	unset EGIT_BRANCH EGIT_COMMIT
	EGIT_SOURCEDIR="${S}/Sources/utils/QtnProperty" \
	EGIT_REPO_URI="https://github.com/lexxmark/QtnProperty.git" \
	git-2_src_unpack
}

src_prepare() {
	cd Sources/utils/QtnProperty
	/usr/lib64/qt5/bin/qmake -r
	cd $S
	/usr/lib64/qt5/bin/qmake
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
	newicon Sources/resources/logo.png "${PN}".png || die
	make_desktop_entry AwesomeBump.sh
}
