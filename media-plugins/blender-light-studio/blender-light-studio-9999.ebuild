# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Lighting system"
HOMEPAGE="https://github.com/leomoon-studios/blender-light-studio"
EGIT_REPO_URI="https://github.com/leomoon-studios/blender-light-studio.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	mv "${S}"/src "${S}"/${PN}
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/${PN}
	fi
}
