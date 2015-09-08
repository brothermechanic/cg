# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. A various sequencer addons"
HOMEPAGE="https://github.com/kinoraw/kinoraw_tools"
EGIT_REPO_URI="https://github.com/kinoraw/kinoraw_tools.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND=">=media-gfx/blender-2.75"

src_install() {
	rm -r {*zip,archive,doc,imgs}
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"
	fi
}
