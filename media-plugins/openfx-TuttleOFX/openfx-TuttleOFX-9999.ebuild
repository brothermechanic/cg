# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="OpenFX. Image processing using OpenCV"
HOMEPAGE="http://www.tuttleofx.org/"
EGIT_REPO_URI="https://github.com/tuttleofx/TuttleOFX.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="dev-lang/python:3.5/3.5m
	dev-python/numpy
	media-libs/freetype
	x11-libs/libXt
	media-libs/lcms
	dev-libs/libltdl
	media-libs/libpng:0/16
	virtual/jpeg
	media-libs/libcaca
	media-libs/glew
	media-libs/tiff
	media-libs/openexr
	media-libs/openimageio
	media-gfx/imagemagick
	media-libs/libraw
	virtual/ffmpeg
	media-libs/openjpeg
	virtual/glu
	media-gfx/graphviz
	virtual/jre
	virtual/jdk
	dev-libs/boost	
	"
RDEPEND="${DEPEND}"

CMAKE_BUILD_TYPE="Release"

src_prepare() {
	sed -e "s|COMPONENTS|COMPONENTS thread|" -i ${S}/libraries/tuttle/tests/CMakeLists.txt
	sed -e "s|WRITE |WRITE \${D}\/|" -i ${S}/libraries/sequenceParser/src/CMakeLists.txt
}

src_configure() {
        local mycmakeargs=(
		-DJAVA_HOME="/opt/icedtea-bin-3.0.0_pre09"
		-DTUTTLE_PYTHON_VERSION=3.5
		-DTUTTLE_EXPERIMENTAL=OFF
		-DTUTTLE_PRODUCTION=ON
        )

        cmake-utils_src_configure
}
src_install() {
	cmake-utils_src_install
}