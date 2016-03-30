# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils git-r3

DESCRIPTION="An embeddable expression evaluation engine"
HOMEPAGE="http://www.disneyanimation.com/technology/seexpr.html"
EGIT_REPO_URI="https://github.com/devernay/SeExpr.git"

LICENSE="Disney"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -e '/ADD_SUBDIRECTORY (src\/doc)/,$d' -i ${S}/CMakeLists.txt || die
}
src_configure() {
	local mycmakeargs=""
	mycmakeargs="${mycmakeargs}
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DCMAKE_BUILD_TYPE=Release
		"
	cmake-utils_src_configure
}
