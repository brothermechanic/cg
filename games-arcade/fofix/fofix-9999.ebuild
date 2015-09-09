# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python2_7 )
inherit git-2 eutils distutils-r1

DESCRIPTION="A game of musical skill and fast fingers"
HOMEPAGE="http://code.google.com/p/fofix/"
EGIT_REPO_URI="https://github.com/fofix/fofix.git"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	dev-python/cython
	virtual/ffmpeg
	virtual/glu
	virtual/libffi
	dev-python/pyogg
	dev-lang/python:2.7
	dev-python/cerealizer
	virtual/python-imaging
	dev-python/numpy
	dev-python/pyopengl
	dev-python/pygame
	dev-python/pysqlite
	dev-python/pyvorbis
	media-libs/libsoundtouch
	dev-python/pyaudio
	"
RDEPEND="${DEPEND}"

scr_prepare() {
	esetup.py --inplace --force
}

scr_compile() {
	distutils-r1_python_compile --inplace --force
}

src_install() {
	chmod -R 777 .
	dolib ${S}/fofix/lib/_VideoPlayer.so || die
	insinto /opt/fofix
	doins -r ${S}/*
	echo "#/bin/sh" > fofix.sh
	echo "python2 /opt/fofix/FoFiX.py" >> fofix.sh
	dobin fofix.sh
	newicon "${S}"/data/fofix_icon.png "${PN}".png
	make_desktop_entry fofix.sh "FOFIX"
}