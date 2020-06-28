# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python2_7 )

inherit toolchain-funcs python-any-r1 cmake-utils eutils

DESCRIPTION="Intel SPMD Program Compiler"
HOMEPAGE="https://ispc.github.com/"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ispc/ispc.git"
	KEYWORDS=""
else
	SRC_URI="https://github.com/${PN}/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="BSD BSD-2 UoI-NCSA"
SLOT="0"
IUSE="examples"

RDEPEND="
	>=sys-devel/clang-3.0:*
	>=sys-devel/llvm-3.0:*
	"
DEPEND="
	${RDEPEND}
	${PYTHON_DEPS}
	sys-devel/bison
	sys-devel/flex
	"

CMAKE_BUILD_TYPE=Release

src_configure() {
	default
	local mycmakeargs=(
	-DCMAKE_INSTALL_PREFIX="/usr"
	-DISPC_INCLUDE_EXAMPLES=$(usex examples)
	-DISPC_NO_DUMPS=ON
	)
	cmake-utils_src_configure
}

src_install() {
	dobin ispc
	dodoc README.rst

	if use examples; then
		insinto "/usr/share/doc/${PF}/examples"
		docompress -x "/usr/share/doc/${PF}/examples"
		doins -r examples/*
	fi
}
