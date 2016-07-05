# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils eutils

DESCRIPTION="krename ported to kf5"
HOMEPAGE="https://github.com/sandsmark/krename"
EGIT_REPO_URI="https://github.com/sandsmark/krename.git"

LICENSE="GPL-2"
SLOT="5"
KEYWORDS="~amd64"
IUSE="debug exif pdf taglib truetype"

RDEPEND="
	exif? ( >=media-gfx/exiv2-0.13:= )
	pdf? ( >=app-text/podofo-0.8 )
	taglib? ( >=media-libs/taglib-1.5 )
	truetype? ( media-libs/freetype:2 )
	kde-frameworks/kdelibs4support
"
DEPEND="${RDEPEND}
	sys-devel/gettext
"

DOCS=( AUTHORS README TODO )

src_prepare() {
    sed -i '/TAGLIB_INCLUDE_DIR.*/a INCLUDE_DIRECTORIES( /usr/include/KF5/KDELibs4Support )' src/CMakeLists.txt
}

src_configure() {
	local mycmakeargs=(
		$(cmake-utils_use_with exif Exiv2)
		$(cmake-utils_use_with taglib)
		$(cmake-utils_use_with pdf LIBPODOFO)
		$(cmake-utils_use_with truetype Freetype)
	)

	cmake-utils_src_configure
}
