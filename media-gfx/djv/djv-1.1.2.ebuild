# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils eutils gnome2-utils xdg-utils

DESCRIPTION="Professional movie playback and image processing software."
HOMEPAGE="http://djv.sourceforge.net/"
SRC_URI="https://github.com/darbyjohnston/DJV/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="ffmpeg jpeg png quicktime tiff qt5"

RDEPEND="
	media-libs/glm
	qt5? (
		dev-qt/qtopengl:5
		dev-qt/qtconcurrent:5
		dev-qt/linguist-tools:5
		dev-qt/qtsvg:5
	)
	media-libs/glew
	ffmpeg? ( media-video/ffmpeg )
	media-libs/openexr
	jpeg? ( virtual/jpeg )
	png? ( media-libs/libpng )
	quicktime? ( media-libs/libquicktime )
	tiff? ( media-libs/tiff )
"

DEPEND="${RDEPEND}
	dev-util/cmake"

CMAKE_BUILD_TYPE="Release"

PATCHES=( "${FILESDIR}"/ffmpeg.patch )

S=${WORKDIR}/DJV-${PV}

src_prepare() {
	cmake-utils_src_prepare

	sed -i '/enable_testing()/d' CMakeLists.txt || die
	sed -i '/add_subdirectory(tests)/d' CMakeLists.txt || die

	sed -i -e "/CMP0020 OLD/d" CMakeLists.txt || die
	sed -i -e "/add_subdirectory(doc)/d" CMakeLists.txt || die
	sed -i -e "s:throw (djvError):noexcept(false):g" $(find . -type f -name '*.h') || die
	sed -i -e "s:throw (djvError):noexcept(false):g" $(find . -type f -name '*.cpp') || die
	sed -i -e "s:throw (QString):noexcept(false):g" $(find . -type f -name '*.h') || die
	sed -i -e "s:throw (QString):noexcept(false):g" $(find . -type f -name '*.cpp') || die
	sed -i -e "s:DESTINATION lib:DESTINATION $(get_libdir):g" $(find . -type f -name 'CMakeLists.txt') || die
	sed -i -e "s:DESTINATION lib:DESTINATION $(get_libdir):g" $(find . -type f -name '*.cmake') || die
	sed -i -e "s:djvPackageThirdParty true:djvPackageThirdParty false:" CMakeLists.txt || die
	sed -i -e "s|^Exec.*|Exec=djv_view %U|" etc/Linux/djv_view.desktop.in || die
	sed -i -e "s|^Categories.*|Categories=AudioVideo;|" etc/Linux/djv_view.desktop.in || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DDJV_THIRD_PARTY=/usr/$(get_libdir)
		-DBUILD_SHARED_LIBS=ON
	)

	cmake-utils_src_configure
}

src_install() {
#	rm etc/Linux/djv_view.desktop
	cmake-utils_src_install
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}
