# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib eutils git-r3

DESCRIPTION="Professional movie playback and image processing software."
HOMEPAGE="http://djv.sf.net"
EGIT_REPO_URI="https://github.com/sobotka/djv-view.git"
EGIT_COMMIT="44a063755e627c70498d948478e29ffc1d3f105d"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
# IUSE="ffmpeg jpeg png quicktime tiff qt"

RDEPEND="
		>=dev-qt/qtopengl-5.3.2
		>=dev-qt/qtconcurrent-5.3.2
		>=dev-qt/linguist-tools-5.3.2
		>=dev-qt/qtsvg-5.3.2
		>=media-libs/openexr-2.2.0
		>=media-libs/glew-1.11.0
		>=media-video/ffmpeg-2.4.1
		virtual/jpeg
		>=media-libs/libpng-1.6.13
		>=media-libs/libquicktime-1.2.4
		>=media-libs/tiff-4.0.3
"

DEPEND="${RDEPEND}
	>=dev-util/cmake-2.4.4"

PATCHES=( "${FILESDIR}"/ffmpeg.patch )


S=${WORKDIR}/${P}

src_prepare() {
	cmake-utils_src_prepare
	sed -i -e "/CMP0020 OLD/d" CMakeLists.txt || die
	sed -i -e "/add_subdirectory(doc)/d" CMakeLists.txt
	sed -i -e "s:throw (djvError):noexcept(false):g" $(find . -type f -name '*.h')
	sed -i -e "s:throw (djvError):noexcept(false):g" $(find . -type f -name '*.cpp')
	sed -i -e "s:throw (QString):noexcept(false):g" $(find . -type f -name '*.h')
	sed -i -e "s:throw (QString):noexcept(false):g" $(find . -type f -name '*.cpp')
	sed -i -e "s:DESTINATION lib:DESTINATION $(get_libdir):g" $(find . -type f -name 'CMakeLists.txt')
	sed -i -e "s:DESTINATION lib:DESTINATION $(get_libdir):g" $(find . -type f -name '*.cmake')
	sed -i -e "s:djvPackageThirdParty true:djvPackageThirdParty false:" CMakeLists.txt || die
	sed -i -e "s|^Exec.*|Exec=djv_view %U|" etc/Linux/djv_view.desktop.in || die
	sed -i -e "s|^Categories.*|Categories=AudioVideo;|" etc/Linux/djv_view.desktop.in || die
}

src_install() {
#	rm etc/Linux/djv_view.desktop
	cmake-multilib_src_install
}
