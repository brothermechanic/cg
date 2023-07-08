# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=maturin

inherit distutils-r1

MY_PN="laz-rs-python"
DESCRIPTION="Python bindings for the laz-rs crate."
HOMEPAGE="https://pypi.org/project/lazrs"
SRC_URI="https://github.com/laz-rs/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 hppa ~ia64 ~mips x86"

RESTRICT="mirror"

S=${WORKDIR}/${MY_PN}-${PV}
