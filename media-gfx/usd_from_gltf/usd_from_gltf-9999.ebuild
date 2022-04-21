# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
EAPI=6

CMAKE_ECLASS="cmake"

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
    dev-python/pillow[${PYTHON_USEDEP}]
    ')
    dev-lang/nasm
    dev-cpp/nlohmann_json
    media-libs/draco
    media-libs/giflib
    dev-libs/stb
    media-libs/libpng
    media-libs/libjpeg-turbo
    dev-cpp/tclap
    dev-libs/boost
    media-libs/openusd"

DEPEND="${RDEPEND}"
CMAKE_BUILD_TYPE=Release

pkg_setup() {
    python-single-r1_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
	sed -i '15,18d' gltf/CMakeLists.txt
	sed -i '1,24d;66,104d' process/CMakeLists.txt
	sed -i '15,18d' usd_from_gltf/CMakeLists.txt
	sed -i '29,31d' CMakeLists.txt
	sed -e '/${USD_LIBS}/a \  python3.7m' -e '/${USD_LIBS}/a \  boost_python37' -e '/${USD_LIBS}/a \  png' -e '/${USD_LIBS}/a \  turbojpeg' -e '/${USD_LIBS}/a \  draco' -e '/${USD_LIBS}/a \  gif' -e '/${USD_LIBS}/a \  stb_image' -i usd_from_gltf/CMakeLists.txt
}

src_configure() {
    local mycmakeargs=(
        -Djson_INCLUDE_DIR="/usr/include/nlohmann"
        -Ddraco_INCLUDE_DIR="/usr/include/draco"
        -DUSD_INCLUDE_DIRS="/usr/local/include"
        -Dtclap_INCLUDE_DIR="/usr/include/tclap"
		-DUSD_DIR="/opt/openusd/lib"
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPython_INCLUDE_DIRS="$(python_get_includedir)"
        )
	cmake-utils_src_configure
}
