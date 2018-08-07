# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="5"

inherit toolchain-funcs eutils

DESCRIPTION="A LALR(1) parser generator."
HOMEPAGE="http://www.hwaci.com/sw/lemon/"
SRC_URI="http://sqlite.org/2015/sqlite-src-3081101.zip"
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

S=${WORKDIR}/sqlite-src-3081101

src_unpack() {
	unpack ${A}
	cd ${S}/tool/
	epatch "$FILESDIR/lemon.patch"
}

src_compile() {
	cd ${S}/tool/
	"$(tc-getCC)" -o lemon lemon.c || die
}

src_install() {
	cd ${S}/tool/
	dodir /usr/share/lemon/
	insinto /usr/share/lemon/
	doins lempar.c
	dobin lemon
}
