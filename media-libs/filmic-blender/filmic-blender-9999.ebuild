# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Filmic View and Look Transformations for Blender"
HOMEPAGE="https://sobotka.github.io/filmic-blender/"
EGIT_REPO_URI="https://github.com/sobotka/filmic-blender.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons,opencolorio]"

BVER="/usr/share/blender/*"

src_install() {
	insinto ${BVER}/datafiles/colormanagement/
	doins -r "${S}"/*
}

pkg_preinst() {
    mv ${BVER}/datafiles/colormanagement/ ${BVER}/datafiles/colormanagement.orig/
}

pkg_postrm() {
    mv ${BVER}/datafiles/colormanagement.orig/ ${BVER}/datafiles/colormanagement/
}
