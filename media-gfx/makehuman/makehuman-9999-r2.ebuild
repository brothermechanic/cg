# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit mercurial

PYTHON_COMPAT=( python2_7 )

DESCRIPTION="Software for the modelling of 3D humanoid characters."
HOMEPAGE="http://www.makehuman.org/"
EHG_REPO_URI="https://bitbucket.org/MakeHuman/makehuman"
EHG_REVISION="stable"
#SRC_URI="http://download.tuxfamily.org/${PN}/releases/1.0.2/${PN}-1.0.2_all.deb"
SRC_URI="http://http.debian.net/debian/pool/main/m/makehuman/makehuman_1.1.0~git20150707.orig.tar.gz"

LICENSE="AGPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="aqsis blender python_targets_python2_7"

RDEPEND="
	dev-python/pyopengl[python_targets_python2_7]
	dev-python/numpy[python_targets_python2_7]
	dev-python/PyQt4[python_targets_python2_7]
	media-libs/sdl-image
	media-libs/mesa
	media-libs/glew
	blender? ( media-gfx/blender )
	aqsis? ( media-gfx/aqsis )
	"

DEPEND="${RDEPEND}"

src_unpack() {
	unpack $A
#	unpack ./data.tar.bz2
	mercurial_src_unpack
}

src_prepare() {
	sed "s|^python makehuman.py "$@"|python2 makehuman.py "$@"|" -i makehuman/makehuman
	sed -i 's|python"|python2"|' "${S}"/buildscripts/build_prepare.py
}

src_compile() {
	cd ${S}/makehuman/buildscripts
	python2 build_prepare.py ${S}/makehuman ${S}/build
	cd ${S}/build/makehuman
	find . -type f -name "*.py" -exec sed -i 's/^#!.*python$/&2/' '{}' ';'
	python2 -m compileall .
	python2 -OO -m compileall .

}

src_install() {
	INST_DIR="${D}opt/makehuman"
	install -d -m755 $INST_DIR
	cp -r "${S}"/makehuman/* $INST_DIR
	install -d -m755 "${D}usr/bin/"
	cp -a "${FILESDIR}/makehuman_launcher.sh" "${D}usr/bin/makehuman"
	install -d -m755 "${D}usr/share/doc/makehuman"
	cp -a docs/* "${D}usr/share/doc/makehuman/"
	install -d -m755 "${D}usr/share/applications"
	cp -a "${FILESDIR}/makehuman.desktop" "${D}usr/share/applications"
	install -d -m755 "${D}usr/share/pixmaps"
	cp -a "${FILESDIR}/makehuman.png" "${D}usr/share/pixmaps/"
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/blendertools/*
	fi
#	cp -r "${WORKDIR}"/usr/share/makehuman/data/* ${INST_DIR}/data/ || die
	cp -r "${WORKDIR}"/makehuman-1.1.0~git20150707/makehuman/data/* ${INST_DIR}/data/ || die
}