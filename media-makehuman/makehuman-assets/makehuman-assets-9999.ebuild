# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="These are the assets which are bundled with MakeHuman releases"
HOMEPAGE="https://github.com/makehumancommunity/makehuman-assets"
EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman-assets.git"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	egit_clean
    insinto /usr/share/makehuman/plugins/
	doins -r "${S}"/*
}
