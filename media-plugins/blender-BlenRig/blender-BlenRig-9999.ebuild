# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Auto-rigging and skinning system"
HOMEPAGE="https://cloud.blender.org/p/blenrig/"
EGIT_REPO_URI="https://gitlab.com/jpbouza/BlenRig.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	rm -r "${S}"/.*
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"
	fi
}
