# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit mercurial

DESCRIPTION="MakeHuman eXchange format 2"
HOMEPAGE="https://bitbucket.org/ThomasMakeHuman/mhx2-makehuman-exchange"
EHG_REPO_URI="https://bitbucket.org/ThomasMakeHuman/mhx2-makehuman-exchange"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="blender"

DEPEND="media-gfx/makehuman"
RDEPEND="${RDEPEND}
	 blender? ( media-gfx/blender )
	 "

src_install() {
	insinto /opt/makehuman/plugins/
	doins -r "${S}"/9_export_mhx2
	if use blender; then
	      if VER="/usr/share/blender/*";then
		  insinto ${VER}/scripts/addons/
		  doins -r "${S}"/import_runtime_mhx2
	      fi
	fi
}
