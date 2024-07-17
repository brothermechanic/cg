# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic linux-info toolchain-funcs

DESCRIPTION="Collection of high-performance ray tracing kernels"
HOMEPAGE="https://www.embree.org"
SRC_URI="https://github.com/RenderKit/embree/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="
	Apache-2.0
	static-libs? (
		BSD
		BZIP2
		MIT
		ZLIB
	)
	tutorials? (
		Apache-2.0
		MIT
	)
"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64 ~arm64"
X86_CPU_FLAGS=(
	avx:avx
	avx2:avx2
	avx512f:avx512f
	avx512vl:avx512vl
	avx512bw:avx512bw
	avx512dq:avx512dq
	avx512cd:avx512cd
	sse2:sse2
	sse4_2:sse4_2
)
ARM_CPU_FLAGS=(
	neon:neon
	neon2x:neon2x
)
CPU_FLAGS=(
	${ARM_CPU_FLAGS[@]/#/cpu_flags_arm_}
	${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}
)

IUSE+="
${CPU_FLAGS[@]%:*}
backface-culling -compact-polys -custom-cflags custom-optimization debug doc doc-docfiles
doc-html doc-images man +hardened +filter-function ispc raymask -ssp static-libs sycl +tbb test tutorials
"
REQUIRED_USE+="
	cpu_flags_x86_avx? (
		cpu_flags_x86_sse4_2
	)
	cpu_flags_x86_avx2? (
		cpu_flags_x86_avx
	)
	cpu_flags_x86_avx512f? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512vl
		cpu_flags_x86_avx512bw
		cpu_flags_x86_avx512dq
		cpu_flags_x86_avx512cd
	)
	cpu_flags_x86_avx512vl? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
		cpu_flags_x86_avx512bw
		cpu_flags_x86_avx512dq
		cpu_flags_x86_avx512cd
	)
	cpu_flags_x86_avx512bw? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
		cpu_flags_x86_avx512vl
		cpu_flags_x86_avx512dq
		cpu_flags_x86_avx512cd
	)
	cpu_flags_x86_avx512dq? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
		cpu_flags_x86_avx512vl
		cpu_flags_x86_avx512bw
		cpu_flags_x86_avx512cd
	)
	cpu_flags_x86_avx512cd? (
		cpu_flags_x86_avx2
		cpu_flags_x86_avx512f
		cpu_flags_x86_avx512vl
		cpu_flags_x86_avx512bw
		cpu_flags_x86_avx512dq
	)
	cpu_flags_x86_sse4_2? (
		cpu_flags_x86_sse2
	)
	|| (
		${CPU_FLAGS[@]%:*}
	)
	test? (
		tutorials
	)
"

BDEPEND="
	>=dev-build/cmake-3.2.0
	virtual/pkgconfig
	doc? (
		app-text/pandoc
		dev-texlive/texlive-xetex
	)
	doc-html? (
		app-text/pandoc
		media-gfx/imagemagick[jpeg]
	)
	doc-images? (
		media-gfx/imagemagick[jpeg]
		media-gfx/xfig
	)
	ispc? (
		>=dev-lang/ispc-1.17.0
	)
"
RDEPEND="
	>=media-libs/glfw-3.2.1
	media-libs/libglvnd
	tbb? ( >=dev-cpp/tbb-2021.9:= )
	sycl? ( dev-libs/intel-compute-runtime[l0] )
	tutorials? (
		<media-libs/openimageio-2.3.5.0[-cxx17(-),-abi8-compat,-abi9-compat]
		media-libs/libpng:0=
		virtual/jpeg:0
	)
"
RDEPEND+="${DEPEND}"

DOCS=( CHANGELOG.md README.md readme.pdf )

RESTRICT="mirror"

pkg_setup() {
	if use kernel_linux ; then
		CONFIG_CHECK="~TRANSPARENT_HUGEPAGE"
		WARNING_TRANSPARENT_HUGEPAGE="Not enabling Transparent Hugepages (CONFIG_TRANSPARENT_HUGEPAGE) will impact rendering performance."
		linux-info_pkg_setup
		if ! ( cat "${BROOT}/proc/cpuinfo" | grep sse2 > "${BROOT}/dev/null" ) ; then
			die "You need a CPU with at least sse2 support."
		fi
	fi

	if use doc-html ; then
		if has network-sandbox $FEATURES ; then
			eerror
			eerror "${PN} requires network-sandbox to be disabled in FEATURES to be able to"
			eerror "use MathJax for math rendering."
			eerror
			die
		fi
		ewarn
		ewarn "Building package may exhibit random failures with doc-html USE flag."
		ewarn "Emerge and try again."
		ewarn
	fi
}

src_prepare() {
	cmake_src_prepare

	# disable RPM package building
	sed -e 's|CPACK_RPM_PACKAGE_RELEASE 1|CPACK_RPM_PACKAGE_RELEASE 0|' \
		-i CMakeLists.txt || die

	# raise cmake minimum version to silence warning
	sed -e 's#CMAKE_MINIMUM_REQUIRED(VERSION 3.[0-9].0)#CMAKE_MINIMUM_REQUIRED(VERSION 3.5)#I' \
	    -i \
	        CMakeLists.txt \
	        kernels/rthwif/CMakeLists.txt \
	        tutorials/embree_info/CMakeLists.txt \
	        tutorials/minimal/CMakeLists.txt \
	    || die
}

src_configure() {
	# -Werror=odr
	# https://bugs.gentoo.org/859838
	# https://github.com/embree/embree/issues/481
	filter-lto

	# NOTE: You can make embree accept custom CXXFLAGS by turning off
	# EMBREE_IGNORE_CMAKE_CXX_FLAGS. However, the linking will fail if you use
	# any "m*" compile flags. This is because embree builds modules for the
	# different supported ISAs and picks the correct one at runtime.
	# "m*" will pull in cpu instructions that shouldn't be in specific modules
	# and it fails to link properly.
	# https://github.com/embree/embree/issues/115

	filter-flags -m*
    CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DBUILD_DOC=$(usex doc)
		-DCMAKE_SKIP_INSTALL_RPATH:BOOL=ON
		# default
		-DEMBREE_BACKFACE_CULLING=$(usex backface-culling)
		-DEMBREE_BACKFACE_CULLING_CURVES=$(usex backface-culling)
		-DEMBREE_BACKFACE_CULLING_SPHERES=$(usex backface-culling)

		-DEMBREE_COMPACT_POLYS=$(usex compact-polys)
		-DEMBREE_FILTER_FUNCTION=$(usex filter-function)
		-DEMBREE_GEOMETRY_CURVE=ON 			# default
		-DEMBREE_GEOMETRY_GRID=ON 			# default
		-DEMBREE_GEOMETRY_INSTANCE=ON 		# default
		-DEMBREE_GEOMETRY_POINT=ON 			# default
		-DEMBREE_GEOMETRY_QUAD=ON 			# default
		-DEMBREE_GEOMETRY_SUBDIVISION=ON	# default
		-DEMBREE_GEOMETRY_TRIANGLE=ON		# default
		-DEMBREE_GEOMETRY_USER=ON			# default
		-DEMBREE_IGNORE_CMAKE_CXX_FLAGS=OFF
		-DEMBREE_IGNORE_INVALID_RAYS=ON

		# Set to NONE so we can manually switch on ISAs below
		-DEMBREE_MAX_ISA:STRING="NONE"
		-DEMBREE_ISA_AVX=$(usex cpu_flags_x86_avx)
		-DEMBREE_ISA_AVX2=$(usex cpu_flags_x86_avx2)
		-DEMBREE_ISA_AVX512=$(usex cpu_flags_x86_avx512dq)
		# TODO look into neon 2x support
		-DEMBREE_ISA_NEON=$(usex cpu_flags_arm_neon)
		-DEMBREE_ISA_NEON2X=$(usex cpu_flags_arm_neon2x)
		-DEMBREE_ISA_SSE2=$(usex cpu_flags_x86_sse2)
		-DEMBREE_ISA_SSE42=$(usex cpu_flags_x86_sse4_2)
		-DEMBREE_ISPC_SUPPORT=$(usex ispc)
		-DEMBREE_RAY_MASK=$(usex raymask)
		-DEMBREE_SYCL_SUPPORT=$(usex sycl)
		-DEMBREE_SYCL_LARGEGRF=$(usex sycl)
		-DEMBREE_RAY_PACKETS=ON
		-DEMBREE_STACK_PROTECTOR=$(usex ssp)
		-DEMBREE_STATIC_LIB=$(usex static-libs)
		-DEMBREE_STAT_COUNTERS=OFF
		-DEMBREE_TASKING_SYSTEM:STRING=$(usex tbb "TBB" "INTERNAL")
		-DHARDENED=$(usex hardened)
		-DEMBREE_TUTORIALS=$(usex tutorials)
		-DEMBREE_ZIP_MODE=OFF
	)

	local last_o=$(echo "${CFLAGS}" \
		| tr " " "\n" \
		| grep -E -e "-O(0|1|2|3|4|Ofast)( |$)" \
		| tail -n 1)
	if use custom-optimization ; then
		mycmakeargs+=( -DCUSTOM_OPTIMIZATION_LEVEL="${last_o}" )
	fi

	if use tutorials; then
		use ispc && \
		mycmakeargs+=( -DEMBREE_ISPC_ADDRESSING:STRING="64" )
		mycmakeargs+=(
			-DEMBREE_TUTORIALS_LIBJPEG=ON
			-DEMBREE_TUTORIALS_LIBPNG=ON
			-DEMBREE_TUTORIALS_OPENIMAGEIO=ON
		)
	fi

	if use cpu_flags_arm_neon2x ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="NEON2X" )
	elif use cpu_flags_arm_neon ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="NEON" )
	elif use cpu_flags_x86_avx512f \
		&& use cpu_flags_x86_avx512cd \
		&& use cpu_flags_x86_avx512dq \
		&& use cpu_flags_x86_avx512bw \
		&& use cpu_flags_x86_avx512vl
	then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="AVX512" )
	elif use cpu_flags_x86_avx2 ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="AVX2" )
	elif use cpu_flags_x86_avx ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="AVX" )
	elif use cpu_flags_x86_sse4_2 ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="SSE4.2" )
	elif use cpu_flags_x86_sse2 ; then
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="SSE2" )
	else
		mycmakeargs+=( -DEMBREE_MAX_ISA:STRING="NONE" )
	fi

	if use tbb ; then
		mycmakeargs+=(
			-DTBB_INCLUDE_DIR="${ESYSROOT}/usr/include/oneapi"
			-DTBB_LIBRARY_DIR="${ESYSROOT}/usr/$(get_libdir)"
			-DTBB_SOVER=$(echo $(basename $(realpath "${ESYSROOT}/usr/$(get_libdir)/libtbb.so")) | cut -f 3 -d ".")
		)
	fi

	if use test; then
		mycmakeargs+=(
			-DBUILD_TESTING=ON
			-DEMBREE_TESTING_INSTALL_TESTS=OFF
			-DEMBREE_TESTING_INTENSITY=4
			# These tutorials are not used by the default tests
			-DEMBREE_TUTORIALS_GLFW=OFF
			-DEMBREE_TUTORIALS_INSTALL=OFF
			-DEMBREE_TUTORIALS_LIBJPEG=OFF
			-DEMBREE_TUTORIALS_LIBPNG=OFF
			-DEMBREE_TUTORIALS_OPENIMAGEIO=OFF
			-DCMAKE_DISABLE_FIND_PACKAGE_OpenImageIO="yes"
		)
	fi

	cmake_src_configure
}

src_test() {
	# NOTE Some Embree tests will fail due to EMBREE_BACKFACE_CULLING settings for blender...
	local CMAKE_SKIP_TESTS=(
		'^embree_verify$'
		'^embree_verify_i2$'
		'^viewer_models_curves_round_line_segments_3.ecs$'
		'^viewer_models_curves_round_line_segments_7.ecs$'
		'^viewer_models_curves_round_line_segments_8.ecs$'
		'^viewer_models_curves_round_line_segments_9.ecs$'
		'^viewer_coherent_models_curves_round_line_segments_3.ecs$'
		'^viewer_coherent_models_curves_round_line_segments_7.ecs$'
		'^viewer_coherent_models_curves_round_line_segments_8.ecs$'
		'^viewer_coherent_models_curves_round_line_segments_9.ecs$'
		'^viewer_quad_coherent_models_curves_round_line_segments_3.ecs$'
		'^viewer_quad_coherent_models_curves_round_line_segments_7.ecs$'
		'^viewer_quad_coherent_models_curves_round_line_segments_8.ecs$'
		'^viewer_quad_coherent_models_curves_round_line_segments_9.ecs$'
		'^viewer_grid_coherent_models_curves_round_line_segments_3.ecs$'
		'^viewer_grid_coherent_models_curves_round_line_segments_7.ecs$'
		'^viewer_grid_coherent_models_curves_round_line_segments_8.ecs$'
		'^viewer_grid_coherent_models_curves_round_line_segments_9.ecs$'
		'^hair_geometry$'
		'^embree_tests$'
	)

	cmake_src_test
}
