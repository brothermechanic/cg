# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=( python{3_6,3_7} )

inherit git-2 python-single-r1 

DESCRIPTION="Open source tool for making 3d characters."
HOMEPAGE="http://www.makehumancommunity.org/"

EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman.git"
SRC_URI="assets? ( https://github.com/makehumancommunity/makehuman-assets/archive/v1.1.1.tar.gz )"

EGIT_BRANCH="master"

LICENSE="|| ( AGPL-3 CC0 )"
SLOT="9999"
KEYWORDS=""
IUSE="+assets"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
	dev-python/PyQt5[${PYTHON_USEDEP}]
	dev-qt/qtsvg"

DEPEND="${RDEPEND}"

src_unpack() {
	git-2_src_unpack
	for tarball in ${A}; do
		[[ "${tarball}" == ${P}.tar.gz ]] && continue
		unpack "${tarball}"
	done
}

src_prepare(){
	if use assets; then
		cp -dpR ${WORKDIR}/makehuman-assets-1.1.1/base/* ${S}/${PN}/data/ || die
	fi
}

src_install() {
	rm -r ${S}/${PN}/data/skins || die
	exeinto /usr/bin
	doexe ${FILESDIR}/${PN}
	domenu ${S}/buildscripts/deb/debian/MakeHuman.desktop
	doicon ${S}/${PN}/icons/makehuman.png
	insinto /usr/share/${PN}/
	doins -r ${PN}/* || die "doins share failed"
}

