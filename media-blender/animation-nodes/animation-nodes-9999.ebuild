# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_6 )
inherit git-r3 eutils python-r1 versionator

DESCRIPTION="Blender addon. The nodes to create animations."
HOMEPAGE="http://blenderartists.org/forum/showthread.php?350296-Addon-Animation-Nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation_nodes.git"
EGIT_BRANCH="v2.1"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

#local mydistutilsargs=( --export --noversioncheck )



src_compile() {
    python_setup 'python3*'
}

src_install() {
    rm -r animation_nodes
	unpack animation_nodes.zip ${A}
	if VER="/usr/share/blender/*";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"/animation_nodes
	fi
}
