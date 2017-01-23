# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Interactive field-aligned mesh generator"
HOMEPAGE="http://igl.ethz.ch/projects/instant-meshes/"
EGIT_REPO_URI="https://github.com/wjakob/instant-meshes.git"

LICENSE="InstantMeshes"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-cpp/tbb
	x11-libs/libXrandr
	x11-libs/libXinerama
	x11-libs/libXcursor
	x11-libs/libXi"

RDEPEND="
    ${DEPEND}
    gnome-extra/zenity"

src_prepare() {
	epatch "${FILESDIR}"/tbb.patch
cmake-utils_src_prepare
}

src_configure() {
    rm -r ext/tbb
	local mycmakeargs=""
	mycmakeargs=(
        -DTBB_BUILD_STATIC=OFF
	)
	cmake-utils_src_configure
}

src_install() {
	mv ${BUILD_DIR}/"Instant Meshes" ${BUILD_DIR}/InstantMeshes
	dobin ${BUILD_DIR}/InstantMeshes
	newicon resources/icon.png "${PN}".png
	make_desktop_entry InstantMeshes "Mesh Generator"
}
