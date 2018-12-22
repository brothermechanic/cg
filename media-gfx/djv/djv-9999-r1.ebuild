# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils eutils git-r3

DESCRIPTION="Professional movie playback and image processing software."
HOMEPAGE="http://djv.sourceforge.net/"
EGIT_REPO_URI="https://github.com/darbyjohnston/DJV.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# IUSE="ffmpeg jpeg png quicktime tiff qt"

RDEPEND="
		media-libs/glm
		dev-qt/qtopengl
		dev-qt/qtconcurrent
		dev-qt/linguist-tools
		dev-qt/qtsvg
		media-libs/glew
		media-video/ffmpeg
		media-libs/openexr
		virtual/jpeg
		media-libs/libpng
		media-libs/libquicktime
		media-libs/tiff
"

DEPEND="${RDEPEND}
	dev-util/cmake"

CMAKE_BUILD_TYPE="Release"

S=${WORKDIR}/${P}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
	)

	cmake-utils_src_configure
}
