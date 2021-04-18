# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
#WIP
#WIP
#WIP
EAPI=7

inherit eutils

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"

VERSION="2.90.0"
COMMIT="62aa103d485f"
PACKAGE="blender-${VERSION}-${COMMIT}-linux64"

SRC_URI="https://builder.blender.org/download/${PACKAGE}.tar.xz -> ${P}.tar.xz"

LICENSE="|| ( GPL-2 BL )"
SLOT="29"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PACKAGE}"

src_prepare() {
    default
    sed -e 's|Exec=blender|Exec=/opt/blender-bin|' -i ${S}/blender.desktop || die
    sed -e 's|Icon=blender|Icon=blender-symbolic.svg|' -i ${S}/blender.desktop || die
    mv ${S}/blender ${S}/blender-bin
    mv ${S}/blender.desktop ${S}/blender-bin.desktop
}

src_install() {
    insinto /opt/blender-bin
    doins -r ${S}/*
    exeinto /opt/blender-bin
    doexe ${S}/blender-bin
    domenu ${S}/blender-bin.desktop
    doicon ${S}/blender-symbolic.svg
}

pkg_postinst() {
    elog
    elog "this build updates very often"
    elog "for getting new versions"
    elog "you must change"
    elog "COMMIT="4db63b648643""
    elog
}

pkg_postrm() {
    ewarn ""
    ewarn "You may want to remove the following directory."
    ewarn "~/.config/${PN}/${MY_PV}/cache/"
    ewarn "It may contain extra render kernels not tracked by portage"
    ewarn ""
}
