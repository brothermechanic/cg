# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 autotools eutils

DESCRIPTION="Keeping per-window keyboard layout X11"
HOMEPAGE="https://github.com/antonbutanaev/PerWindowLayout"
EGIT_REPO_URI="https://github.com/antonbutanaev/PerWindowLayout.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-base/xorg-server"
RDEPEND="${DEPEND}"

src_prepare() {
	eapply_user
	eautoreconf
}
