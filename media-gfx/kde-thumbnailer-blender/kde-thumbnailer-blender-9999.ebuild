# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

EGIT_REPO_URI="https://github.com/kayosiii/kde-thumbnailer-blender.git"

inherit cmake-utils eutils git-2

DESCRIPTION="to create thumbnails for blend files in KDE"
HOMEPAGE="https://github.com/kayosiii/kde-thumbnailer-blender"
EGIT_COMMIT="9f36bc3" #for kde4 support

LICENSE="GPL-3"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND=""

RDEPEND="${DEPEND}"
