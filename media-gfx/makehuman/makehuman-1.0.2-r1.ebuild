# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils

PYTHON_COMPAT=( python2_7 )

DESCRIPTION="Software for the modelling of 3D humanoid characters."
HOMEPAGE="http://www.makehuman.org/"
SRC_URI="http://download.tuxfamily.org/${PN}/releases/${PV}/${P}_all.deb"

LICENSE="GPL-3"
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

S="${WORKDIR}"

src_unpack() {
	unpack $A
	unpack ./data.tar.bz2
}

src_install() {
	insinto /
	doins -r "${S}"/usr
	if VER="/usr/share/blender/*";then
	    insinto ${VER}/scripts/addons/
	    doins -r "${S}"/usr/share/makehuman/blendertools/
	fi
}	