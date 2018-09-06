# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

FORTRAN_NEEDED=fortran
# NOTE:The build for multiple python versions should be possible but complecated for the build system
PYTHON_COMPAT=( python2_7 python3_{3,4,5,6} )

inherit eutils toolchain-funcs fortran-2 python-single-r1 cmake-utils

MY_P="med-${PV}"

DESCRIPTION="A library to store and exchange meshed data or computation results"
HOMEPAGE="http://www.salome-platform.org/"
SRC_URI="http://files.salome-platform.org/Salome/other/${MY_P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc fortran mpi python static-libs test"

REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RDEPEND="
	sci-libs/hdf5[fortran=,mpi=]
	mpi? ( virtual/mpi[fortran=] )
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}
	python? ( >=dev-lang/swig-2.0.9:0 )
"

S=${WORKDIR}/${MY_P}_SRC

PATCHES=(
	"${FILESDIR}/${P}-cmake-fortran.patch"
	"${FILESDIR}/${P}-disable-python-compile.patch"
	"${FILESDIR}/${P}-mpi.patch"
	"${FILESDIR}/${P}-hdf5-1.10-support.patch"  # taken from Debian
	"${FILESDIR}/${P}-cmakelist.patch"
	"${FILESDIR}/${P}-tests.patch"
	"${FILESDIR}/${P}-tests-python3.patch"
)

DOCS=( AUTHORS COPYING COPYING.LESSER ChangeLog NEWS README TODO )

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use fortran && fortran-2_pkg_setup
}

src_prepare() {
	# fixes for correct libdir name
	sed -i -e "s@SET(_install_dir lib/python@SET(_install_dir $(get_libdir)/python@" \
		./python/CMakeLists.txt || die "sed failed"
	for cm in ./src/CMakeLists.txt ./tools/medimport/CMakeLists.txt
	do
		sed -i -e "s@INSTALL(TARGETS \(.*\) DESTINATION lib)@INSTALL(TARGETS \1 DESTINATION $(get_libdir))@" \
			"${cm}" || die "sed on ${cm} failed"
	done

	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DMEDFILE_BUILD_FORTRAN="$(usex fortran)"
		-DMEDFILE_BUILD_STATIC_LIBS="$(usex static-libs)"
		-DMEDFILE_BUILD_PYTHON="$(usex python)"
		-DMEDFILE_BUILD_TESTS="$(usex test)"
		-DMEDFILE_INSTALL_DOC="$(usex doc)"
		-DMEDFILE_USE_MPI="$(usex mpi)"
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# the optimization done in CMakeLists.txt has been disabled so
	# we need to do it manually
	use python && python_optimize

	# Remove documentation
	! use doc && rm -rf "${D}/usr/share/doc"

	# Prevent test executables being installed
	use test && rm -rf "${D}/usr/bin/"{testc,testf,usescases}
}

src_test() {
	# override parallel mode only for tests
	local myctestargs=(
		"-j 1"
	)
	cmake-utils_src_test
}
