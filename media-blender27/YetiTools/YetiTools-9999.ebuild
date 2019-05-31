# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Blender addon. YeTiVision studio's Blender tools."
HOMEPAGE="https://github.com/brothermechanic/YetiTools"
EGIT_REPO_URI="https://github.com/brothermechanic/YetiTools.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r {Leeloo.blend,YetiTools.py}
	fi
}
