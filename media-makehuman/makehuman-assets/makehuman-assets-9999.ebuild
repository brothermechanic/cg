# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="These are the assets which are bundled with MakeHuman releases"
HOMEPAGE="http://www.makehumancommunity.org/"
EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman-assets.git"

LICENSE="CC0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    media-gfx/makehuman"


src_install() {
	insinto /usr/share/makehuman/data/
	doins -r ${S}/base/* || die "doins share failed"
}
