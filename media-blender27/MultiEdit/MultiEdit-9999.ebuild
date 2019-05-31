# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Blender addon for editing of multiple objects"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?339369-MultiEdit-%28alpha-1%29-Multiple-Objects-Editing!"
EGIT_REPO_URI="https://github.com/antoni4040/MultiEdit-Addon.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"/MultiEdit_1_1.py
	fi
}
