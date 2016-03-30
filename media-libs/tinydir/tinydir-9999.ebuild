# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Lightweight, portable and easy to integrate C directory and file reader"
HOMEPAGE="https://github.com/cxong/tinydir"
EGIT_REPO_URI="https://github.com/cxong/tinydir.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

src_install() {
	insinto /usr/include/tinydir/
	doins -r "${S}"/*
}
