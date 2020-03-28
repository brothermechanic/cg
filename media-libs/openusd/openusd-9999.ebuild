# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{7,8} )

inherit git-r3 cmake-utils python-single-r1 flag-o-matic

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
EGIT_REPO_URI="https://github.com/PixarAnimationStudios/USD.git"
EGIT_BRANCH="dev"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="python"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	>=dev-libs/boost-1.72:=
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.72:=[python,${PYTHON_MULTI_USEDEP}]
		')
	)"

DEPEND="${RDEPEND}
	virtual/pkgconfig"


pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	cmake-utils_src_configure
}

