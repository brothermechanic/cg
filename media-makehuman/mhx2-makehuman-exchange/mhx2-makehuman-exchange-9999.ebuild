# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit mercurial git-r3

DESCRIPTION="MHX2 - MakeHuman eXchange format 2"
HOMEPAGE="https://bitbucket.org/Diffeomorphic/mhx2-makehuman-exchange/overview"
EGIT_REPO_URI="https://github.com/makehumancommunity/mhx2-makehuman-exchange.git"
LICENSE="AGPL-3.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
    media-gfx/makehuman
    media-gfx/blender"


src_install() {
	insinto /usr/share/makehuman/plugins/
	doins -r ${S}/9_export_mhx2 || die "doins share failed"
	insinto ${BLENDER_ADDONS_DIR}/addons/
	doins -r "${S}"/import_runtime_mhx2
}
