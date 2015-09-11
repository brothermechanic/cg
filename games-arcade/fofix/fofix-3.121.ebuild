# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
 
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1
 
DESCRIPTION="A game of musical skill and fast fingers"
HOMEPAGE="http://code.google.com/p/fofix/"
SRC_URI="https://github.com/fofix/fofix/archive/Release_${PV}.tar.gz"
LICENSE="GPL-2"

SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	virtual/ffmpeg
	virtual/glu
	virtual/libffi
	dev-python/pyogg[${PYTHON_USEDEP}]
	dev-python/cerealizer[${PYTHON_USEDEP}]
	virtual/python-imaging[${PYTHON_USEDEP}]
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/pyopengl[${PYTHON_USEDEP}]
	dev-python/pygame[${PYTHON_USEDEP}]
	dev-python/pysqlite[${PYTHON_USEDEP}]
	dev-python/pyvorbis[${PYTHON_USEDEP}]
	dev-python/pyaudio[${PYTHON_USEDEP}]
	media-libs/libtheora
	media-libs/libsoundtouch
	"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-Release_${PV}/src"

python_install() {
        insinto /opt/fofix
        doins -r ${WORKDIR}/${PN}-Release_${PV}/{data,src}
        exeinto /opt/fofix/
        doexe FoFiX.py
        echo "#/bin/sh" > fofix.sh
        echo "cd /opt/fofix/src" >> fofix.sh
        echo "${EPYTHON} ./FoFiX.py" >> fofix.sh
        dobin fofix.sh
        newicon ${WORKDIR}/${PN}-Release_${PV}/data/fofix_icon.png "${PN}".png
        make_desktop_entry fofix.sh "FOFIX"
}