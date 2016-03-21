# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit

PYTHON_COMPAT=( python2_7 )

DESCRIPTION="Software for the modelling of 3D humanoid characters."
HOMEPAGE="http://www.makehuman.org/"
SRC_URI="http://ppa.launchpad.net/makehuman-official/makehuman-11x/ubuntu/pool/main/m/makehuman/makehuman_1.1.0~rc2+20160305161451.orig.tar.gz"

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

S="${WORKDIR}"/makehuman


src_install() {
	dobin ${WORKDIR}/extras/makehuman || die
	insinto /usr/share/applications
	doins ${WORKDIR}/extras/MakeHuman.desktop
	insinto /usr/share
	doins -r "${WORKDIR}"/makehuman
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/blendertools/*
	fi
}	