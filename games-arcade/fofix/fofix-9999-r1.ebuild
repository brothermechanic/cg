# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
 
EGIT_REPO_URI="https://github.com/fofix/fofix.git"
PYTHON_COMPAT=( python2_7 )
inherit distutils-r1 git-r3
 
DESCRIPTION="A game of musical skill and fast fingers"
HOMEPAGE="http://code.google.com/p/fofix/"
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

python_install() {
        insinto /opt/fofix
        doins -r ${S}/*
        exeinto /opt/fofix/
        doexe FoFiX.py
        insinto /opt/fofix/fofix
        doins -r ${BUILD_DIR}/lib/fofix/lib
        echo "#/bin/sh" > fofix.sh
        echo "cd /opt/fofix" >> fofix.sh
        echo "${EPYTHON} /opt/fofix/FoFiX.py" >> fofix.sh
        dobin fofix.sh
        newicon "${S}"/data/fofix_icon.png "${PN}".png
        make_desktop_entry fofix.sh "FOFIX"
}