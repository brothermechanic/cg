# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2

DESCRIPTION="Blender addon. Import bundler scene to blender"
HOMEPAGE="https://github.com/soniquev8/VSFMBundle_to_Blender"
EGIT_REPO_URI="https://github.com/soniquev8/VSFMBundle_to_Blender.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/"import vsfm.py"
	fi
}
