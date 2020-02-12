# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python{3_7,3_8} )

inherit git-r3 python-single-r1 desktop eutils

DESCRIPTION="Open source tool for making 3d characters."
HOMEPAGE="http://www.makehumancommunity.org/"
EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman.git"
EGIT_BRANCH="master"

LICENSE="|| ( AGPL-3 CC0 )"
SLOT="9999"
KEYWORDS=""
IUSE="+assets"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/numpy
	dev-python/pyopengl
	dev-python/PyQt5
	dev-qt/qtsvg"

DEPEND="${RDEPEND}"

src_install() {
	rm -r ${S}/${PN}/data/skins || die
	exeinto /usr/bin
	doexe ${FILESDIR}/${PN}
	domenu ${FILESDIR}/MakeHuman.desktop || die
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}

pkg_postinst() {
	elog
	elog "For now you must manually add makehuman assets from"
	elog "https://download.tuxfamily.org/makehuman/assets/1.2/base/"
	elog "or"
	elog "https://github.com/makehumancommunity/makehuman-assets"
	elog "to your local makehuman base dir"
	elog "for ex"
	elog "~/makehuman/v1py3/data/"
	elog
}

