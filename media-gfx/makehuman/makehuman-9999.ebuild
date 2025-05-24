# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{11..13} )

inherit python-single-r1 desktop git-r3

DESCRIPTION="Open source tool for making 3d characters."
HOMEPAGE="http://www.makehumancommunity.org/"

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman.git"
	EGIT_BRANCH="master"
	EGIT_CLONE_TYPE="shallow"
	KEYWORDS=""
else
	SRC_URI="https://github.com/makehumancommunity/makehuman/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64"
fi

LICENSE="
	|| ( AGPL-3 CC0 )
	assets? ( CC0-1.0 )
"
SLOT="0"
IUSE="+assets"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="dev-vcs/git-lfs"
RDEPEND="${PYTHON_DEPS}
	dev-python/numpy
	dev-python/pyopengl
	dev-python/pyqt5
	dev-qt/qtsvg
"

DEPEND="${RDEPEND}"

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		unpack "${A}"
	fi
# BUG The account responsible for the budget should increase it to restore access
#   if use assets; then
#		EGIT_LFS="yes"
#		EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman-assets"
#		EGIT_CHECKOUT_DIR=${S}/${PN}/data
#		git-r3_src_unpack
#	fi
}

src_install() {
	rm -r ${S}/${PN}/data/skins || die
	exeinto /usr/bin
	doexe ${FILESDIR}/${PN}
	domenu ${FILESDIR}/MakeHuman.desktop || die
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}

pkg_postinst() {
	if use assets; then
	elog
	elog "For now you must manually add makehuman assets from"
	elog "https://download.tuxfamily.org/makehuman/assets/1.2/base/"
	elog "or"
	elog "https://github.com/makehumancommunity/makehuman-assets"
	elog "to your local makehuman base dir"
	elog "for ex"
	elog "~/makehuman/v1py3/data/"
	elog
	fi
}
