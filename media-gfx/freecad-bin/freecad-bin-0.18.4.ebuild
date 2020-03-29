# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

DESCRIPTION="The 3D CAD/CAE parametric modeling application."
HOMEPAGE="https://freecadweb.org/"
SRC_URI="https://github.com/FreeCAD/FreeCAD/releases/download/${PV}/FreeCAD_0.18-16146-Linux-Conda_Py3Qt5_glibc2.12-x86_64.AppImage"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	!media-gfx/freecad
"
RDEPEND="${DEPEND}"

S=${DISTDIR}

src_install() {
	newbin FreeCAD_0.18-16146-Linux-Conda_Py3Qt5_glibc2.12-x86_64.AppImage ${PN}
	newicon ${FILESDIR}/*.png ${PN}.png
	make_desktop_entry ${PN} FreeCAD
}
