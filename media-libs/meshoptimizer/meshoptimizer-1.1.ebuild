# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Mesh optimization library that makes meshes smaller and faster to render"
HOMEPAGE="https://github.com/zeux/meshoptimizer"
LICENSE="MIT"
SLOT="0"

if [[ ${PV} != *9999* ]]; then
	SRC_URI="https://github.com/zeux/meshoptimizer/archive/refs/tags/v${PV}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~x86 ~arm ~arm64"
else
	inherit git-r3
	EGIT_REPO_URI="https://github.com/zeux/meshoptimizer.git"
fi

IUSE="+gltfpack"

RDEPEND="${DEPEND}"

RESTRICT="mirror test"

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DMESHOPT_BUILD_SHARED_LIBS=ON
		-DMESHOPT_BUILD_DEMO=OFF
		-DMESHOPT_BUILD_GLTFPACK=$(usex gltfpack)
	)

	cmake_src_configure
}
