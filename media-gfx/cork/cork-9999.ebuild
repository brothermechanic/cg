# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 18 19 20 )

inherit git-r3 llvm-r1

DESCRIPTION="Cork - a powerful standalone boolean calculations software"
HOMEPAGE="https://github.com/gilbo/cork"
EGIT_REPO_URI="https://github.com/gilbo/cork"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
	')
    dev-libs/gmp[cxx]
"

src_install() {
	dobin bin/*
	dolib.so lib/*
	doheader include/*
}
