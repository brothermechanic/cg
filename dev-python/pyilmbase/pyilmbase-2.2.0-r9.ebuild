# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{2_7,3_6} )

inherit eutils autotools python-single-r1 multilib-minimal

DESCRIPTION="ilmbase Python bindings"
HOMEPAGE="http://www.openexr.com"
SRC_URI="http://download.savannah.gnu.org/releases/openexr/${P}.tar.gz"
LICENSE="BSD"

SLOT="0"
KEYWORDS="~amd64"
IUSE="+numpy"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEP}
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]"

RDEPEND="
	${PYTHON_DEP}
	>=media-libs/ilmbase-${PV}:=[${MULTILIB_USEDEP}]
	>=dev-libs/boost-1.62.0-r1[${MULTILIB_USEDEP},python(+),${PYTHON_USEDEP}]
	numpy? ( >=dev-python/numpy-1.10.4
            dev-libs/boost-numpy )"

AT_M4DIR=m4
PATCHES=(
	"${FILESDIR}/${P}-configure-boost_python.patch"
	"${FILESDIR}/PyImath_python3.patch"
	"${FILESDIR}/configure_ac_python3.patch"
	"${FILESDIR}/imathnumpymodule_cpp.patch"
)

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	sed -e "s:-lpython\$PYTHON_VERSION:$(python_get_LIBS):g" -i configure.ac || die
	eautoreconf
	autoheader
	multilib_copy_sources
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf "$(use_with numpy numpy)"
}

# fails to install successfully if MAKEOPTS is set to use more than one core.
multilib_src_install() {
	EMAKE_SOURCE=${S} emake DESTDIR="${D}" -j1 install
}
