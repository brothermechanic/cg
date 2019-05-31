# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender addon. Cork - a powerful standalone boolean calculations software"
HOMEPAGE="https://github.com/dfelinto/cork-on-blender"
EGIT_REPO_URI="https://github.com/dfelinto/cork-on-blender.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]
        media-blender27/blender-off-addon
        media-gfx/cork"

src_install() {
	egit_clean
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"
	fi
}
