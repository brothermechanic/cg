# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="BSD licensed clone of the GNU libc backtrace facility"
HOMEPAGE="https://netbsd.org/"

SRC_URI="https://github.com/fam007e/libexecinfo/releases/download/v${PV}/${P}.tar.gz -> ${P}.gh.tar.gz"

IUSE="test static-libs"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 arm64 arm x86"

RESTRICT="
	!test? ( test )
	mirror
"

DEPEND="
	sys-libs/musl
	virtual/libelf
	|| ( llvm-runtimes/libunwind sys-libs/libunwind )
"
RDEPEND="${DEPEND}"

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
