# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit

DESCRIPTION="These are the assets which are bundled with MakeHuman releases"
HOMEPAGE="http://www.makehumancommunity.org/"

LICENSE="CC0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	git lfs clone https://github.com/makehumancommunity/makehuman-assets.git
}

src_install() {
	insinto /usr/
	doins -r ${S}/base/* || die "doins share failed"
}
