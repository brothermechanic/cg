# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3 cmake

DESCRIPTION="single-file public domain (or MIT licensed) libraries for C/C++"
HOMEPAGE="https://github.com/nothings/stb"
EGIT_REPO_URI="https://github.com/nothings/stb.git"
LICENSE="|| ( MIT Unlicense )"
SLOT="0"
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE=""

BDEPEND=""
RDEPEND=""

CMAKE_BUILD_TYPE=Release

src_prepare() {
	cp ${FILESDIR}/* ${S}/ || die
	default
	cmake_src_prepare
}

src_install() {
	doheader -r *.h
	dolib.so ${BUILD_DIR}/libstb_image.so || die
}
