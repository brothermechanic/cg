# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

FORTRAN_NEEDED=fortran
FORTRAN_NEED_OPENMP=1

PYTHON_COMPAT=( python2_7 python3_6 )

inherit eutils toolchain-funcs fortran-2 python-single-r1 cmake-utils autotools flag-o-matic

MY_P="med-${PV}"

DESCRIPTION="A library to store and exchange meshed data or computation results"
HOMEPAGE="http://www.salome-platform.org/"
SRC_URI="http://files.salome-platform.org/Salome/other/${MY_P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc fortran python static-libs test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RDEPEND="
	sci-libs/hdf5[fortran=]
	sys-cluster/openmpi[fortran=]
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9:0 )
"
CMAKE_BUILD_TYPE="Release"

S=${WORKDIR}/${MY_P}_SRC

DOCS=( AUTHORS ChangeLog INSTALL README )

src_prepare() {
    #epatch "${FILESDIR}/hdf5-1.10-support.patch"
    epatch "${FILESDIR}/${P}-cmake-fortran.patch"
    epatch "${FILESDIR}/${P}-nosymlink.patch"
    eapply_user
    eautoreconf -vfi
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use fortran && fortran-2_pkg_setup
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DMEDFILE_BUILD_FORTRAN="$(usex fortran)"
		-DMEDFILE_BUILD_STATIC_LIBS="$(usex static-libs)"
		-DMEDFILE_INSTALL_DOC="$(usex doc)"
		-DMEDFILE_BUILD_PYTHON="$(usex python)"
		-DMEDFILE_BUILD_TESTS="$(usex test)"
	)

	cmake-utils_src_configure
}
