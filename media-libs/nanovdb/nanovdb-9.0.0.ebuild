EAPI=7

inherit cmake

DESCRIPTION="A lightweight GPU friendly version of VDB"
HOMEPAGE="http://www.openvdb.org"
IUSE="abi6-compat abi7-compat abi8-compat benchmark +blosc +cuda doc examples +intrinsics opencl +openvdb optix static-libs test utils -sm_30 -sm_35 -sm_50 -sm_52 -sm_61 -sm_70 -sm_75 -sm_86"

SRC_URI="https://github.com/AcademySoftwareFoundation/openvdb/archive/feature/${PN}/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
REQUIRED_USE="
"

RDEPEND="
	>=dev-cpp/tbb-2021.4.0:=
	>=dev-libs/boost-1.70.0:=
	dev-libs/jemalloc:=
	dev-libs/log4cplus:=
	media-libs/glfw
	media-libs/glu
	sys-libs/zlib:=
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXinerama
	x11-libs/libXrandr
	blosc? ( dev-libs/c-blosc:= )
	cuda? ( >dev-util/nvidia-cuda-toolkit-11.0.0 )
	optix? ( dev-libs/optix )
	openvdb? ( media-gfx/openvdb )
"

DEPEND="${RDEPEND}"

BDEPEND="
	virtual/pkgconfig
	doc? (
		app-doc/doxygen
	)
	test? ( dev-cpp/gtest )
"


S=${WORKDIR}/openvdb-feature-${PN}/${PN}/${PN}

src_prepare() {
	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" docs/CMakeLists.txt || die

	cp ../../cmake/FindLog4cplus.cmake cmake/FindLog4cplus.cmake || die
	cp ../../cmake/FindOpenVDB.cmake cmake/FindOpenVDB.cmake || die
	cp ../../cmake/FindTBB.cmake cmake/FindTBB.cmake || die
	cp ../../cmake/OpenVDBUtils.cmake cmake/OpenVDBUtils.cmake || die

	sed -i -e "s|IlmBase REQUIRED COMPONENTS Half|Imath REQUIRED COMPONENTS Half|" cmake/FindOpenVDB.cmake || die
	sed -i -e "s|_OPENVDB_VISIBLE_DEPENDENCIES IlmBase::Half|_OPENVDB_VISIBLE_DEPENDENCIES Imath::Half|" cmake/FindOpenVDB.cmake || die

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local myprefix="${EPREFIX}/usr"

	if use openvdb; then
		local version
		if use abi6-compat; then
			version=6;
		elif use abi7-compat; then
			version=7;
        elif use abi8-compat; then
			version=8;
		else
			die "Openvdb abi version not compatible"
		fi
		append-cppflags -DOPENVDB_ABI_VERSION_NUMBER=${version}
	fi

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${myprefix}"
		-DNANOVDB_BUILD_BENCHMARK=$(usex benchmark ON OFF)
		-DNANOVDB_BUILD_DOCS=$(usex doc ON OFF)
		-DNANOVDB_BUILD_UNITTESTS=$(usex test ON OFF)
		-DNANOVDB_BUILD_TOOLS=$(usex utils ON OFF)
		-DNANOVDB_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DNANOVDB_USE_BLOSC=$(usex blosc ON OFF)
		-DNANOVDB_USE_CUDA=$(usex cuda ON OFF)
		-DNANOVDB_USE_OPENCL=$(usex opencl ON OFF)
		-DNANOVDB_USE_OPENGL=ON
		-DNANOVDB_USE_OPENVDB=$(usex openvdb ON OFF)
		-DNANOVDB_USE_OPTIX=$(usex optix ON OFF)
		-DOptiX_INCLUDE_DIR=/opt/optix/include
		-DNANOVDB_USE_MAGICAVOXEL=OFF
		-DNANOVDB_USE_INTRINSICS=$(usex intrinsics ON OFF)
		-DNANOVDB_USE_TBB=ON
		-DNANOVDB_USE_ZLIB=ON
		-DNANOVDB_ALLOW_FETCHCONTENT=OFF
	)

	local CUDA_ARCH=""
	if use cuda; then
		for CA in 30 35 50 52 61 70 75 86; do
			use sm_${CA} && CUDA_ARCH+="${CA},"
		done
		[ -n "${CUDA_ARCH}" ] && mycmakeargs+=( -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCH::-1} )
	fi

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
