EAPI=7

inherit git-r3

DESCRIPTION="Socket server for makehuman"
HOMEPAGE="https://github.com/makehumancommunity/community-plugins-socket"
EGIT_REPO_URI="https://github.com/makehumancommunity/community-plugins-socket.git"

LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    media-gfx/makehuman"


src_install() {
	insinto /usr/share/makehuman/plugins/
	doins -r ${S}/8_server_socket || die "doins share failed"
}
