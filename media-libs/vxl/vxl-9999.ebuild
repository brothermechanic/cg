# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 cmake-utils eutils

DESCRIPTION="C++ libraries for Computer Vision and Image Understanding."
HOMEPAGE="https://sf.net/projects/vxl/"
EGIT_REPO_URI="https://github.com/vxl/vxl.git"
EGIT_BRANCH="master"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=""
DEPEND="
	${RDEPEND}
	dev-util/cmake
	sci-libs/libgeotiff"

CMAKE_BUILD_TYPE=Release

src_configure() {
    sed -i "/set(_compilers_destination vcl./,+2d" ${S}/vcl/CMakeLists.txt || die
	local mycmakeargs=(
	-DVXL_USE_DCMTK=OFF
	-DBUILD_SHARED_LIBS=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mv "${ED}/usr/lib" "${ED}/usr/$(get_libdir)" || die "mv failed"
}
