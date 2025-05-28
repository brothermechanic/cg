# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit cmake python-single-r1

DESCRIPTION="Open framework for storing and sharing scene data"
HOMEPAGE="https://www.alembic.io/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="examples hdf5 python test"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	examples? ( python )
"
RESTRICT="!test? ( test ) mirror"

DEPEND="
	${PYTHON_DEPS}
	>=dev-libs/imath-3.1.11-r1:=
	hdf5? (
		>=sci-libs/hdf5-1.10.2:=[zlib(+)]
		>=sys-libs/zlib-1.2.11-r1
	)
	python? (
		dev-libs/imath:=[python,${PYTHON_SINGLE_USEDEP}]
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.53.0[python,${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
"
BDEPEND="
	>=dev-build/cmake-3.13
	python? (
		$(python_gen_cond_dep '
			dev-python/setuptools[${PYTHON_USEDEP}]
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-1.8.3-0001-find-py-ilmbase-in-config-mode.patch"
	"${FILESDIR}/${PN}-1.8.6-py312.patch"
)

DOCS=( ACKNOWLEDGEMENTS.txt FEEDBACK.txt NEWS.txt README.txt )

src_prepare() {
	cmake_src_prepare
	# Fix libdir
	sed -i -r -e 's|(SET[^"]+ lib)(.*)|\1\$\{LIB_SUFFIX\}\2|' CMakeLists.txt lib/Alembic/CMakeLists.txt || die
	# PyAlembic test doesn't properly find Imath, comment it for now
	# cmake_run_in python/PyAlembic cmake_comment_add_subdirectory Tests
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DALEMBIC_BUILD_LIBS=ON
		-DALEMBIC_DEBUG_WARNINGS_AS_ERRORS=OFF
		-DALEMBIC_SHARED_LIBS=ON
		# currently does nothing but require doxygen
		-DDOCS_PATH=OFF
		-DUSE_ARNOLD=OFF
		-DUSE_BINARIES=ON
		-DUSE_EXAMPLES=$(usex examples)
		-DUSE_HDF5=$(usex hdf5)
		-DUSE_MAYA=OFF
		-DUSE_PRMAN=OFF
		-DUSE_PYALEMBIC=$(usex python)
		-DUSE_TESTS=$(usex test)
		$(usex python "-DPython3_EXECUTABLE=${PYTHON}" "")
	)

	cmake_src_configure
}

# Some tests may fail if run in parallel mode.
# See https://github.com/alembic/alembic/issues/401
src_test() {
	cmake_src_test -j1
}
