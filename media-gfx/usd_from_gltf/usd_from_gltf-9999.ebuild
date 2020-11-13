# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{7..9} )

inherit git-r3 cmake-utils python-single-r1

DESCRIPTION="Command-line tool for converting glTF models to USD"
HOMEPAGE="https://github.com/google/usd_from_gltf"
EGIT_REPO_URI="https://github.com/google/usd_from_gltf.git"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="
    $(python_gen_cond_dep '
    dev-python/pillow[${PYTHON_MULTI_USEDEP}]
    ')
    dev-lang/nasm
    dev-cpp/nlohmann_json
    media-libs/draco
    media-libs/giflib"

DEPEND="${RDEPEND}"

pkg_setup() {
    python-single-r1_pkg_setup
}

src_configure() {
    local mycmakeargs=(
		-Djson_DIR="/usr/lib64/cmake/nlohmann_json"
		-Ddraco_DIR="/usr/lib64/cmake/drako"
		-Dgiflib_DIR="${S}/tools/ufginstall/patches/giflib"
        )
	cmake-utils_src_configure
}
