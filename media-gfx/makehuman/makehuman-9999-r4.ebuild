# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit mercurial

PYTHON_COMPAT=( python2_7 )

DESCRIPTION="Software for the modelling of 3D humanoid characters."
HOMEPAGE="http://www.makehuman.org/"
EHG_REPO_URI="https://bitbucket.org/MakeHuman/makehuman"
EHG_REVISION="default"

LICENSE="AGPL"
SLOT="0"
KEYWORDS=""
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

PDEPEND="blender? ( media-plugins/makehuman-mhx2 )"

S=${WORKDIR}/${P}

src_prepare() {
	sed "s|^python makehuman.py "$@"|python2 makehuman.py "$@"|" -i ${S}/makehuman/makehuman
	cd ${S}/buildscripts
	sed -i 's|python"|python2"|' build_prepare.py
	sed -i 's|#noDownload = False|noDownload = False|' build.conf.example
	mkdir ${S}/makehuman/buildscripts
	cp build.conf.example ${S}/makehuman/buildscripts/build.conf
}

src_compile() {
	cd ${S}
	python2 buildscripts/build_prepare.py ${S}/makehuman ${S}/build
	cd ${S}/makehuman
	find . -type f -name "*.py" -exec sed -i 's/^#!.*python$/&2/' '{}' ';' 
	python2 -m compileall . 
	python2 -OO -m compileall . 
	python2 download_assets.py 

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
}