# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit kde5 git-r3

DESCRIPTION="Tiling script for kwin"
HOMEPAGE="https://github.com/faho/kwin-tiling"
LICENSE="GPL-2+"
KEYWORDS="~amd64 ~arm ~arm64 ~x86"
IUSE=""
EGIT_REPO_URI="https://github.com/faho/kwin-tiling.git"


src_configure() {
 plasmapkg2 --type kwinscript -i .
}
