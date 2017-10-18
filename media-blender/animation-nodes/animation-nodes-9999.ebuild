# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender addon. The nodes to create animations."
HOMEPAGE="http://blenderartists.org/forum/showthread.php?350296-Addon-Animation-Nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation_nodes.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
	if VER="/usr/share/blender/*";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"
	fi
}
