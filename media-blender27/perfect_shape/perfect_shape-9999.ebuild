# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender addon. Shape Extrude Tool"
HOMEPAGE="http://blenderartists.org/forum/showthread.php?389974-Addon-Perfect-Shape-Shape-Extrude-Tool"
EGIT_REPO_URI="https://github.com/crantisz/perfect_shape.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	egit_clean
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"/perfect_shape
	fi
}
