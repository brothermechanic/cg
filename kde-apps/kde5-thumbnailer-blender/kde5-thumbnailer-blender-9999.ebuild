# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=7



inherit cmake eutils git-r3

DESCRIPTION="Blender thumbnail generator for KDE"
HOMEPAGE="https://github.com/kayosiii/kde-thumbnailer-blender"
EGIT_REPO_URI="https://github.com/kayosiii/kde-thumbnailer-blender.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

RDEPEND="
	kde-frameworks/kio
	!kde-apps/thumbnailers"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/zstandard.patch"
	)
