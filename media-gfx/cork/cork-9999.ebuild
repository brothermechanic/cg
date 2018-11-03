# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils git-r3

DESCRIPTION="Cork - a powerful standalone boolean calculations software"
HOMEPAGE="http://djv.sf.net"
EGIT_REPO_URI="https://github.com/gilbo/cork.git"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="sys-devel/llvm"

DEPEND="${RDEPEND}"

src_install() {
	dobin bin/*
	dolib lib/*
	doheader include/*
}
