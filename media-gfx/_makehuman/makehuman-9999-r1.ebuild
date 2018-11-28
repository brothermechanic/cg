# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_6,3_7} )

inherit git-r3 python-single-r1 

DESCRIPTION="Open source tool for making 3d characters."
HOMEPAGE="http://www.makehumancommunity.org/"

EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman.git"
ASSETS_URI="https://github.com/makehumancommunity/makehuman-assets.git"

LICENSE="|| ( AGPL-3 CC0 )"
SLOT="0"
KEYWORDS=""
IUSE="+assets"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-qt/qtsvg
	assets? ( media-plugins/makehuman-assets )"

DEPEND="${RDEPEND}"

src_install() {
    rm -r ${S}/${PN}/data/skins || die
	exeinto /usr/bin
	doexe ${FILESDIR}/${PN}
	domenu ${S}/buildscripts/deb/debian/MakeHuman.desktop
	doicon ${S}/${PN}/icons/makehuman.svg
	rm -r ${S}/${PN}/data/*
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}

