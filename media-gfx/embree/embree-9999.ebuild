# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit cmake-utils git-r3

DESCRIPTION="Embree ray tracing kernels by intel"
HOMEPAGE="https://embree.github.io"
EGIT_REPO_URI="https://github.com/embree/embree.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+ispc"

RDEPEND="
	ispc? ( dev-lang/ispc )
	dev-cpp/tbb
	"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=""
	if ispc; then
		mycmakeargs="${mycmakeargs} -DEMBREE_ISPC_SUPPORT=ON"
	else
		mycmakeargs="${mycmakeargs} -DEMBREE_ISPC_SUPPORT=OFF"
	fi
	mycmakeargs="${mycmakeargs}
		  -DCMAKE_INSTALL_PREFIX=/usr
		  -DCMAKE_BUILD_TYPE=Release
		  -DENABLE_TUTORIALS=OFF
		  -DTBB_ROOT=/usr"
	cmake-utils_src_configure
}

