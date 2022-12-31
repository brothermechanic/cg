# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{8..11} )

inherit cmake cuda llvm python-single-r1

DESCRIPTION="Library for the efficient manipulation of volumetric data"
HOMEPAGE="https://www.openvdb.org"
SRC_URI="https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0/9.1"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
CUDA_ARCHS="sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86"

IUSE="abi7-compat abi8-compat abi9-compat ax benchmark +blosc cuda doc examples +intrinsics
	nanovdb numpy python static-libs test utils zlib ${CPU_FEATURES[@]%:*} ${CUDA_ARCHS}"

RESTRICT="
	mirror
	!test? ( test )
"

REQUIRED_USE="^^ ( abi7-compat abi8-compat abi9-compat )
	cuda? ( nanovdb )
	blosc? ( zlib )
	ax? ( zlib )
	numpy? ( python )
	intrinsics? ( nanovdb || ( cpu_flags_x86_avx cpu_flags_x86_sse4_2 ) )
	python? ( ${PYTHON_REQUIRED_USE} )
"
RDEPEND="
	>=dev-cpp/tbb-2020.3:=
	dev-libs/boost:=
	dev-libs/jemalloc:=
	dev-libs/log4cplus:=
	>=dev-libs/imath-3.1.4-r2:=[python?]
	zlib? ( sys-libs/zlib:= )
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	ax? ( <sys-devel/llvm-14:= )
	blosc? ( dev-libs/c-blosc:= )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-11 )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[numpy?,python?,${PYTHON_USEDEP}]
			numpy? ( dev-python/numpy[${PYTHON_USEDEP}] )
		')
	)
	utils? (
		media-libs/glfw
		media-libs/glu
		media-libs/libpng:=
		>=media-libs/openexr-3:=
		virtual/opengl
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	test? ( dev-util/cppunit dev-cpp/gtest )
"

LLVM_MAX_SLOT=13

PATCHES=(
	"${FILESDIR}/${PN}-7.1.0-0001-Fix-multilib-header-source.patch"
	"${FILESDIR}/${PN}-8.1.0-glfw-libdir.patch"
	"${FILESDIR}/${PN}-9.0.0-fix-atomic.patch"
	"${FILESDIR}/${PN}-9.0.0-imath-3.patch"
	"${FILESDIR}/${PN}-9.1.0-remesh.patch"
	"${FILESDIR}/${PN}-9.1.0-disable-failing-tests.patch"
)

pkg_setup() {
	use ax && llvm_pkg_setup
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" doc/CMakeLists.txt || die
	sed -i -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" {,${PN}/${PN}/}CMakeLists.txt || die

	cmake_src_prepare

	if use cuda; then
		cuda_add_sandbox -w
		cuda_src_prepare
	fi
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local myprefix="${EPREFIX}/usr/"

	local version
	if use abi7-compat; then
		version=7
	elif use abi8-compat; then
		version=8
	elif use abi9-compat; then
		version=9
	else
		die "OpenVDB ABI version is not compatible"
	fi

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${myprefix}"
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/"
		-DOPENVDB_ABI_VERSION_NUMBER="${version}"
		-DOPENVDB_BUILD_AX=$(usex ax)
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_BUILD_VDB_LOD=$(usex utils)
		-DOPENVDB_BUILD_VDB_RENDER=$(usex utils)
		-DOPENVDB_BUILD_VDB_VIEW=$(usex utils)
		-DOPENVDB_CORE_SHARED=ON
		-DOPENVDB_CORE_STATIC=$(usex static-libs)
		-DOPENVDB_ENABLE_RPATH=OFF
		-DUSE_BLOSC=$(usex blosc)
		-DUSE_CCACHE=OFF
		-DUSE_COLORED_OUTPUT=ON
		-DUSE_EXR=$(usex utils)
		-DUSE_IMATH_HALF=ON
		-DUSE_LOG4CPLUS=ON
		-DUSE_NANOVDB=$(usex nanovdb)
		-DUSE_PNG=$(usex utils)
		-DUSE_ZLIB=$(usex zlib)
		-DCONCURRENT_MALLOC="Tbbmalloc"
	)

	if use abi8-compat; then
		mycmakeargs+=( -DOPENVDB_USE_DEPRECATED_ABI_8=ON )
	elif use abi7-compat; then
		mycmakeargs+=( -DOPENVDB_USE_DEPRECATED_ABI_7=ON )
	fi

	if use ax; then
		mycmakeargs+=(
			-DOPENVDB_AX_STATIC=OFF
			-DOPENVDB_AX_TEST_CMD=OFF # fails
			-DOPENVDB_BUILD_AX_UNITTESTS=$(usex test)
			-DOPENVDB_BUILD_AX_BINARIES=$(usex utils)
		)
	fi

	if use cuda; then
		for CA in ${CUDA_ARCHS}; do
			use ${CA} && CUDA_ARCH+="${CA#sm_*};"
		done
		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH%%;}
			-DNANOVDB_USE_CUDA=ON
		)
	fi

	if use nanovdb; then
		mycmakeargs+=(
			-DNANOVDB_BUILD_UNITTESTS=$(usex test ON OFF)
			-DNANOVDB_BUILD_BENCHMARK=$(usex benchmark ON OFF)
			-DNANOVDB_BUILD_TOOLS=$(usex utils ON OFF)
			-DNANOVDB_BUILD_EXAMPLES=$(usex examples ON OFF)
			-DNANOVDB_USE_BLOSC=$(usex blosc ON OFF)
			-DNANOVDB_USE_OPENVDB=ON
			-DNANOVDB_USE_MAGICAVOXEL=OFF
			-DNANOVDB_USE_INTRINSICS=$(usex intrinsics ON OFF)
			-DNANOVDB_USE_TBB=ON
			-DNANOVDB_USE_ZLIB=$(usex zlib ON OFF)
			-DNANOVDB_ALLOW_FETCHCONTENT=OFF
		)
	fi

	if use python; then
		mycmakeargs+=(
			-DOPENVDB_BUILD_PYTHON_MODULE=ON
			-DUSE_NUMPY=$(usex numpy)
			-DOPENVDB_BUILD_PYTHON_UNITTESTS=$(usex test)
			-DPYOPENVDB_INSTALL_DIRECTORY="$(python_get_sitedir)"
			-DPython_INCLUDE_DIR="$(python_get_includedir)"
		)
	fi

	if use cpu_flags_x86_avx; then
		mycmakeargs+=( -DOPENVDB_SIMD=AVX )
	elif use cpu_flags_x86_sse4_2; then
		mycmakeargs+=( -DOPENVDB_SIMD=SSE42 )
	fi

	cmake_src_configure
}
