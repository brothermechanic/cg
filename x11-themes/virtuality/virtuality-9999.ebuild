# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3 cmake-utils

DESCRIPTION="qt5 widget style"
HOMEPAGE="https://store.kde.org/content/show.php/Virtuality?content=165086"
EGIT_REPO_URI="https://github.com/luebking/virtuality.git"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-qt/qtcore
	kde-plasma/kwin
	"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs=""
	
	mycmakeargs="
		${mycmakeargs}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_INSTALL_PREFIX=/usr
        -DWITH_QT5=ON
        "
        cmake-utils_src_configure
}
