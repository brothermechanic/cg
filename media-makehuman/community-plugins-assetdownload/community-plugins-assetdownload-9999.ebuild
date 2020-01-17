# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="The asset downloader plugin"
HOMEPAGE="https://github.com/makehumancommunity/community-plugins-assetdownload"
EGIT_REPO_URI="https://github.com/makehumancommunity/community-plugins-assetdownload.git"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    media-gfx/makehuman
    media-makehuman/community-plugins-mhapi"


src_install() {
	insinto /usr/share/makehuman/plugins/
	doins -r ${S}/8_asset_downloader || die "doins share failed"
}
