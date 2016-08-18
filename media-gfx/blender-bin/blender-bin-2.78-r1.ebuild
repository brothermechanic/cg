# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"
SRC_URI="http://download.blender.org/release/Blender${PV}/blender-${PV}-testbuild1-linux-glibc219-x86_64.tar.bz2"

LICENSE="GPL-3"
SLOT="1"
KEYWORDS="amd64"
IUSE=""

S="${WORKDIR}"/blender-${PV}-testbuild1-linux-glibc219-x86_64

src_install() {
	insinto /opt/blender
	doins -r ${S}
	dosym ${PV} /usr/share/blender/${PV}-bin
}
