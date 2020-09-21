EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit cmake flag-o-matic python-single-r1

DESCRIPTION="Libs for the efficient manipulation of volumetric data"
HOMEPAGE="http://www.openvdb.org"
SRC_URI="https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cpu_flags_x86_avx cpu_flags_x86_sse4_2 doc libglvnd numpy python static-libs test utils abi6-compat abi7-compat"
REQUIRED_USE="
	numpy? ( python )
	^^ ( abi6-compat abi7-compat )
	python? ( ${PYTHON_REQUIRED_USE} )
"

RDEPEND="
	>=dev-libs/boost-1.70.0
	>=dev-libs/c-blosc-1.5.0
	dev-libs/jemalloc
	dev-libs/log4cplus
	media-libs/glfw
	media-libs/glu
	media-libs/ilmbase:=
	media-libs/openexr
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	libglvnd? ( media-libs/libglvnd )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.70:=[python,${PYTHON_MULTI_USEDEP}]
			dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		')
	)"

DEPEND="${RDEPEND}
	dev-cpp/tbb
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	test? ( dev-util/cppunit )"

PATCHES=(
	"${FILESDIR}/${P}-0001-Fix-multilib-header-source.patch"
	"${FILESDIR}/${PN}-remesh.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" doc/CMakeLists.txt || die
	sed -i -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" {,openvdb/}CMakeLists.txt || die
	sed -i -e "s|  lib|  $(get_libdir)|g" openvdb/CMakeLists.txt || die
	sed -i -e "s/MINIMUM_PYTHON_VERSION 2.7/MINIMUM_PYTHON_VERSION 3.7/g" CMakeLists.txt || die
	sed -i -e "s|PC_IlmBase QUIET IlmBase|PC_IlmBase REQUIRED IlmBase|g" cmake/FindIlmBase.cmake || die
	sed -i -e "s|PC_OpenEXR QUIET OpenEXR|PC_OpenEXR REQUIRED OpenEXR|g" cmake/FindOpenEXR.cmake || die

	cmake_src_prepare
}

src_configure() {
	local myprefix="${EPREFIX}/usr/"

	append-cxxflags -DPY_OPENVDB_USE_NUMPY

	local version
	if use abi6-compat; then
		version=6
	elif use abi7-compat; then
		version=7
	else
		die "Openvdb abi version is not compatible"
	fi

	local mycmakeargs=(
		-DCHOST="${CHOST}"
		-DCMAKE_INSTALL_PREFIX="${myprefix}"
		-DOPENVDB_ABI_VERSION_NUMBER="${version}"
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_BUILD_VDB_LOD=$(usex !utils)
		-DOPENVDB_BUILD_VDB_RENDER=$(usex !utils)
		-DOPENVDB_BUILD_VDB_VIEW=$(usex !utils)
		-DOPENVDB_CORE_SHARED=ON
		-DOPENVDB_CORE_STATIC=$(usex static-libs)
		-DOPENVDB_ENABLE_RPATH=OFF
		-DUSE_CCACHE=OFF
		-DUSE_COLORED_OUTPUT=ON
		-DUSE_EXR=ON
		-DUSE_LOG4CPLUS=ON
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
	)

	use test && mycmakeargs+=( -DCPPUNIT_LOCATION="${myprefix}" )

	if use python; then
		mycmakeargs+=(
			-DOPENVDB_BUILD_PYTHON_MODULE=ON
			-DUSE_NUMPY=$(usex numpy)
			-DPYOPENVDB_INSTALL_DIRECTORY="$(python_get_sitedir)"
			-DPython_EXECUTABLE="${PYTHON}"
		)
	fi

	if use cpu_flags_x86_avx; then
		mycmakeargs+=( -DOPENVDB_SIMD=AVX )
	elif use cpu_flags_x86_sse4_2; then
		mycmakeargs+=( -DOPENVDB_SIMD=SSE42 )
	fi

	cmake_src_configure

	#sed -i "s/isystem/I/g" $(find ${BUILD_DIR} -name flags.make) || die
}
