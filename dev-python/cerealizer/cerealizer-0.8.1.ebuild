 # Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_4} )

inherit distutils-r1

DESCRIPTION="A secure pickle-like module"
HOMEPAGE="http://home.gna.org/oomadness/en/cerealizer/"
SRC_URI="https://pypi.python.org/packages/source/C/Cerealizer/Cerealizer-${PV}.tar.bz2"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 ppc ~amd64"
IUSE=""
S="${WORKDIR}/Cerealizer-${PV}"

DEPEND="dev-lang/python:2.7"
