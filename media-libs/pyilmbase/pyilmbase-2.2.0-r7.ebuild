# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
AUTOTOOLS_AUTORECONF=1
WANT_AUTOMAKE=1.15

PYTHON_COMPAT=( python3_5 )

inherit eutils autotools flag-o-matic python-single-r1

DESCRIPTION="Python bindings for the IlmBase"
HOMEPAGE="http://openexr.com/"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RDEPEND="dev-lang/python
	dev-libs/boost[python]
	media-libs/openexr
	media-libs/ilmbase
	dev-python/numpy
	dev-libs/boost-numpy
	"
DEPEND="${RDEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/PyImath_python3.patch
	epatch "${FILESDIR}"/configure_ac_python3.patch
	epatch "${FILESDIR}"/imathnumpymodule_cpp.patch
	sed -e "s:-lpython\$PYTHON_VERSION:$(python_get_LIBS):g" -i configure.ac || die
	eautoconf
	autoheader
}

src_configure() {
	econf \
		--prefix=/usr \
		--with-boost-python-libname=boost_python-${EPYTHON#python}
}

src_install() {
	einstall -j1 || die "install failed"
}
