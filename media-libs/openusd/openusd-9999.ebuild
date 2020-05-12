# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )

inherit git-r3 cmake-utils python-single-r1 flag-o-matic

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
EGIT_REPO_URI="https://github.com/PixarAnimationStudios/USD.git"
EGIT_COMMIT="4b11629"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="python"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-libs/boost
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.72:=[python,${PYTHON_MULTI_USEDEP}]
		')
	)"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_BUILD_TYPE=Release

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	default
	eapply "${FILESDIR}"/usd.diff
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr/local
		-DPXR_SET_INTERNAL_NAMESPACE=usdBlender
		-DPXR_ENABLE_PYTHON_SUPPORT=OFF
		-DPXR_BUILD_IMAGING=OFF
		-DPXR_BUILD_TESTS=OFF
		-DPXR_BUILD_MONOLITHIC=ON
		-DBUILD_SHARED_LIBS=ON
		-DPXR_BUILD_MONOLITHIC=ON
		-DPXR_BUILD_USD_TOOLS=OFF
		-DPXR_ENABLE_PTEX_SUPPORT=OFF
		-DCMAKE_DEBUG_POSTFIX=_d
	)
	cmake-utils_src_configure
}
