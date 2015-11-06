# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit mercurial

DESCRIPTION="Blender addon. Mitsuba exporter"
HOMEPAGE="https://www.mitsuba-renderer.org/repos/exporters/mitsuba-blender"
EHG_REPO_URI="https://www.mitsuba-renderer.org/repos/exporters/mitsuba-blender"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="=media-gfx/blender-9999"

src_install() {
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/mtsblend
	fi
}
