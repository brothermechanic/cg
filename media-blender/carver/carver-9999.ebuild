# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender28 addon. Multiple tools to carve or to create objects"
HOMEPAGE="https://blenderartists.org/t/carver-mt-for-2-8/1151461"
EGIT_REPO_URI="https://github.com/clarkx/Carver.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender28[addons]"

src_install() {
	egit_clean
	if VER="/usr/share/blender/2.79.80";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"
	fi
}
