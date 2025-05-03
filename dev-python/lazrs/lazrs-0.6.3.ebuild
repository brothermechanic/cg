# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin

CRATES="
	num-traits@0.2.16
	scopeguard@1.2.0
	windows-targets@0.48.5
	unindent@0.1.11
	memoffset@0.9.0
	autocfg@1.1.0
	redox_syscall@0.3.5
	byteorder@1.4.3
	memoffset@0.6.5
	pyo3-macros@0.17.3
	target-lexicon@0.12.11
	quote@1.0.33
	hermit-abi@0.3.2
	smallvec@1.11.0
	lock_api@0.4.10
	unicode-ident@1.0.11
	crossbeam-utils@0.8.16
	pyo3-build-config@0.17.3
	parking_lot@0.12.1
	pyo3-macros-backend@0.17.3
	crossbeam-epoch@0.9.15
	proc-macro2@1.0.66
	parking_lot_core@0.9.8
	rayon-core@1.11.0
	pyo3-ffi@0.17.3
	laz@0.8.2
	crossbeam-channel@0.5.8
	once_cell@1.18.0
	crossbeam-deque@0.8.3
	either@1.9.0
	bitflags@1.3.2
	num_cpus@1.16.0
	indoc@1.0.9
	rayon@1.7.0
	cfg-if@1.0.0
	syn@1.0.109
	pyo3@0.17.3
	windows_x86_64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.48.5
	libc@0.2.147
	windows_x86_64_gnu@0.48.5
	windows_x86_64_msvc@0.48.5
	windows_i686_msvc@0.48.5
	windows_i686_gnu@0.48.5
	windows_aarch64_msvc@0.48.5
"

inherit cargo distutils-r1

MY_PN="laz-rs-python"
DESCRIPTION="Python bindings for the laz-rs crate."
HOMEPAGE="https://pypi.org/project/lazrs"
SRC_URI="https://github.com/laz-rs/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
SRC_URI+="
	${CARGO_CRATE_URIS}
"
LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"

BDEPEND="
	dev-python/setuptools-rust[${PYTHON_USEDEP}]
"

RESTRICT="mirror"

S=${WORKDIR}/${MY_PN}-${PV}
