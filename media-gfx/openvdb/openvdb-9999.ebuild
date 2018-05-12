# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_6 )

inherit cmake-utils flag-o-matic python-single-r1 versionator git-r3

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
EGIT_REPO_URI="https://github.com/dreamworksanimation/openvdb.git"
LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS=""
IUSE="+abi3-compat doc python"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="sys-libs/zlib:=
	>=dev-libs/boost-1.62:=[python?,${PYTHON_USEDEP}]
	media-libs/openexr:=
	media-libs/glfw:=
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXinerama
	x11-libs/libXcursor
	dev-libs/jemalloc
	>=dev-libs/c-blosc-1.5.0
	dev-libs/log4cplus
	python? (
		${PYTHON_DEPS}
		dev-python/numpy[${PYTHON_USEDEP}]
	)"

DEPEND="${RDEPEND}
	virtual/pkgconfig
	dev-cpp/tbb
	doc? ( app-doc/doxygen[latex] )"

CMAKE_BUILD_TYPE=Release
#PATCHES=( "${FILESDIR}"/boost-1.66.patch )
pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local myprefix="${EPREFIX}/usr/"

	# To stay in sync with Boost
	append-cxxflags -std=c++14

	local mycmakeargs=(
		-DOPENVDB_BUILD_UNITTESTS=OFF
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-OPENVDB_ABI_VERSION_NUMBER=3
		-DOPENVDB_ENABLE_RPATH=OFF
		-DUSE_GLFW3=ON
		-DBLOSC_LOCATION="${myprefix}"
		-DGLFW3_LOCATION="${myprefix}"
		-DTBB_LOCATION="${myprefix}"
		-DILMBASE_LOCATION="${myprefix}"
		-DOPENEXR_LOCATION="${myprefix}"
		-DIlmbase_IEX_LIBRARY="/usr/$(get_libdir)/libIex.so"
		-DIlmbase_ILMTHREAD_LIBRARY="/usr/$(get_libdir)/libIlmThread.so"
		-NUMPY_INCL_DIR:="${python_get_sitedir}/site-packages/numpy/core/include/numpy/"
		-BOOST_PYTHON_LIB := -lboost_python-3.6-mt -lboost_numpy
	)

	cmake-utils_src_configure
}

src_install() {
        cmake-utils_src_install
        mv "${ED}/usr/lib" "${ED}/usr/$(get_libdir)" || die "mv failed"
}
