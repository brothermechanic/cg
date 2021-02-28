EAPI=7

inherit cmake flag-o-matic

DESCRIPTION="A lightweight GPU friendly version of VDB"
HOMEPAGE="http://www.openvdb.org"
IUSE="benchmark +cuda doc examples +intrinsics opencl +openvdb optix static-libs test utils"

SRC_URI="https://github.com/AcademySoftwareFoundation/openvdb/archive/feature/${PN}/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
REQUIRED_USE="
"

RDEPEND="
	dev-cpp/tbb
	>=dev-libs/boost-1.70.0
	>=dev-libs/c-blosc-1.5.0
	dev-libs/jemalloc
	dev-libs/log4cplus
	media-libs/glfw
	media-libs/glu
	>=media-libs/ilmbase-2.5.5:=
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	cuda? ( >dev-util/nvidia-cuda-toolkit-11.0.0 )
	optix? ( dev-libs/optix )
	openvdb? ( media-gfx/openvdb )
	"

DEPEND="${RDEPEND}"

BDEPEND="
	>=dev-util/cmake-3.11.4
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
	)
	test? ( dev-cpp/gtest )
"

CMAKE_BUILD_TYPE=Release

S=${WORKDIR}/openvdb-feature-${PN}/${PN}

src_prepare() {
	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" docs/CMakeLists.txt || die
	sed -i -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" CMakeLists.txt || die
	sed -i -e "s|  lib|  $(get_libdir)|g" CMakeLists.txt || die
	cp ../cmake/FindLog4cplus.cmake cmake/FindLog4cplus.cmake || die
	cmake_src_prepare
}

src_configure() {
	local myprefix="${EPREFIX}/usr"

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${myprefix}"
		-DNANOVDB_BUILD_BENCHMARK=$(usex benchmark ON OFF)
		-DNANOVDB_BUILD_DOCS=$(usex doc ON OFF)
		-DNANOVDB_BUILD_UNITTESTS=$(usex test ON OFF)
		-DNANOVDB_BUILD_TOOLS=$(usex utils ON OFF)
		-DNANOVDB_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DNANOVDB_USE_BLOSC=ON
		-DNANOVDB_USE_CUDA=$(usex cuda ON OFF)
		-DNANOVDB_USE_OPENCL=$(usex opencl ON OFF)
		-DNANOVDB_USE_OPENGL=ON
		-DNANOVDB_USE_OPENVDB=$(usex openvdb ON OFF)
		-DNANOVDB_USE_OPTIX=$(usex optix ON)
		-DOptiX_INCLUDE_DIR=/opt/optix/include
		-DNANOVDB_USE_MAGICAVOXEL=OFF
		-DNANOVDB_USE_INTRINSICS=$(usex intrinsics ON OFF)
		-DNANOVDB_USE_TBB=ON
		-DNANOVDB_USE_ZLIB=ON
		-DNANOVDB_ALLOW_FETCHCONTENT=OFF
	)

	cmake_src_configure

	#sed -i "s/isystem/I/g" $(find ${BUILD_DIR} -name flags.make) || die
}

src_install(){
	cmake_src_install

	#Fix headers destination

	local HEADERS_DIR=${ED}/usr/include
	mkdir ${HEADERS_DIR} || die
	mv ${ED}/usr/${PN} ${HEADERS_DIR}/ || die
}
