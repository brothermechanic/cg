# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils mercurial

DESCRIPTION="The software to create realistic 3d humans"
HOMEPAGE="http://www.makehuman.org"
EHG_REPO_URI="https://bitbucket.org/MakeHuman/makehuman"

LICENSE="AGPL3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+assets"

DEPEND=""
RDEPEND="
    dev-python/pyopengl
    dev-python/PyQt4
    assets? ( media-plugins/makehuman-assets )"


src_install() {
    rm -r ${S}/${PN}/data/skins || die
	exeinto /usr/bin
	doexe ${FILESDIR}/${PN}
	domenu ${FILESDIR}/MakeHuman.desktop
	doicon ${FILESDIR}/${PN}.png
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}
