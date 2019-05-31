# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3

DESCRIPTION="Blender addon. Simple time tracker inside blender."
HOMEPAGE="http://blenderartists.org/forum/showthread.php?345129-Time-Tracker-addon"
EGIT_REPO_URI="https://github.com/uhlik/bpy.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	touch system_time_tracker.csv
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		insopts -g users -m0775
		doins -r "${S}"/2.7x/system_time_tracker.py
	fi
}
