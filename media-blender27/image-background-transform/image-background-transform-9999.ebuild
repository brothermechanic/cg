# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="http://lacuisine.tech/2018/04/26/image-background-transform/"
HOMEPAGE="Transform in 3D View background images"
EGIT_REPO_URI="https://github.com/LesFeesSpeciales/image-background-transform.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		doins -r "${S}"/image_background_transform.py
	fi
}
