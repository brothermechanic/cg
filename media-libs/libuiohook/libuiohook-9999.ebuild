# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils autotools

DESCRIPTION="C library to provide global keyboard and mouse hooks from userland."
HOMEPAGE="https://github.com/kwhat/libuiohook"
EGIT_REPO_URI="https://github.com/kwhat/libuiohook.git"
EGIT_BRANCH="master"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}"

src_prepare() {
   default
   eautoreconf
}
