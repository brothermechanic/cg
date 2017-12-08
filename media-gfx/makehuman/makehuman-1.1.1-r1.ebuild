# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="The software to create realistic 3d humans"
HOMEPAGE="http://www.makehuman.org"
SRC_URI="https://launchpad.net/~makehuman-official/+archive/ubuntu/makehuman-11x/+files/makehuman_1.1.1+20170304112533.orig.tar.gz"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    dev-python/pyopengl
    dev-python/PyQt4"

S="${WORKDIR}"

src_unpack() {
	unpack ${A}
}

src_prepare() {
    eapply_user
    sed -e "s|python.|python2 makehuman.py "$@"|" -i ${S}/extras/${PN}
}

src_install() {
	exeinto /usr/bin
	doexe ${S}/extras/${PN}
	domenu ${S}/extras/MakeHuman.desktop
	doicon ${FILESDIR}/${PN}.png
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}
