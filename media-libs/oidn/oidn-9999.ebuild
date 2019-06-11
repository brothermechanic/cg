# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6,7} )

inherit git-r3 cmake-utils python-single-r1 eutils

DESCRIPTION="Intel(R) Open Image Denoise library"
HOMEPAGE="http://www.openimagedenoise.org/"
EGIT_REPO_URI="https://github.com/OpenImageDenoise/oidn.git"
EGIT_BRANCH="master"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	dev-cpp/tbb"
DEPEND="
	${RDEPEND}
	dev-util/cmake"

CMAKE_BUILD_TYPE=Release

pkg_setup() {
	python-single-r1_pkg_setup
}

src_install() {
	cmake-utils_src_install
    dolib ${BUILD_DIR}/libmkldnn.a
}
