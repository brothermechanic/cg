# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="The hard dependency for most community plugins"
HOMEPAGE="https://github.com/makehumancommunity/community-plugins-mhapi"
EGIT_REPO_URI="https://github.com/makehumancommunity/community-plugins-mhapi.git"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    media-gfx/makehuman"


src_install() {
	insinto /usr/share/makehuman/plugins/
	doins -r ${S}/1_mhapi || die "doins share failed"
}
