# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{13..15} )

inherit python-any-r1

DESCRIPTION="BSD licensed clone of the GNU libc backtrace facility"
HOMEPAGE="https://github.com/fam007e/libexecinfo"

SRC_URI="https://github.com/fam007e/libexecinfo/releases/download/v${PV}/${P}.tar.gz -> ${P}.gh.tar.gz"

LICENSE="BSD-2"

SLOT="0"

KEYWORDS="amd64 arm arm64 ~loong ~ppc ~ppc64 ~riscv x86"

IUSE="test static-libs"

DEPEND="${PYTHON_DEPS}"
BDEPEND="
	virtual/libc
	virtual/libelf
	|| ( llvm-runtimes/libunwind sys-libs/libunwind )
"

REQUIRED_USE="!elibc_glibc"

RESTRICT="
	!test? ( test )
	mirror
"

src_compile() {
	local -a targets=(
		dynamic
		$(usex static-libs 'static' '')
	)
	emake prefix="${EPREFIX}/usr" libdir="${EPREFIX}/usr/$(get_libdir)" ${targets[*]}
}

src_test() {
	local -a targets=(
		test-dynamic
		$(usex static-libs 'test' '')
	)
	emake prefix="${EPREFIX}/usr" libdir="${EPREFIX}/usr/$(get_libdir)" ${targets[*]}
	LD_LIBRARY_PATH="${S}" ./test
}

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install
	if ! use static-libs; then
		find "${D}" -name "*.a" -delete || die
	fi
}
