# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

OPENVDB_COMPAT=( {7..12} )
PYTHON_COMPAT=( python3_{10..13} )
LLVM_MAX_SLOT=15

inherit cmake cuda flag-o-matic llvm multibuild python-single-r1 toolchain-funcs openvdb

DESCRIPTION="Library for the efficient manipulation of volumetric data"
HOMEPAGE="https://www.openvdb.org"
OGT_COMMIT="22e71873ffc55c3a6253d31302e4f5e2191f9a0b"
OGT_DFN="ogt-${OGT_COMMIT:0:7}.tar.gz"
SRC_URI="
https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
magicavoxel? ( https://github.com/jpaver/opengametools/archive/${OGT_COMMIT}.tar.gz -> ${OGT_DFN} )
"

LICENSE="MPL-2.0"
SLOT="0/$(ver_cut 1-2)"
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 sm_87 sm_89 sm_90 )
KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
X86_CPU_FLAGS=( avx sse4_2 )
IUSE="
${X86_CPU_FLAGS[@]/#/cpu_flags_x86_} ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
alembic ax +blosc benchmark cuda debug doc -imath-half examples jemalloc jpeg -log4cplus
magicavoxel nanovdb numpy python +static-libs tbbmalloc openexr -png test -utils zlib
"
RESTRICT="
	mirror
	!test? ( test )
"

REQUIRED_USE="
	${OPENVDB_REQUIRED_USE}
	?? (
		jemalloc
		tbbmalloc
	)
	magicavoxel? (
		nanovdb
		examples
	)
	cuda? (
		nanovdb
		|| (
			${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
		)
	)
	numpy? (
		python
	)
	python? (
		${PYTHON_REQUIRED_USE}
	)
	blosc? ( zlib )
"

RDEPEND="
	dev-libs/boost:=
	zlib? ( >=sys-libs/zlib-1.2.7:= )
	dev-libs/imath:=
	ax? (
		<llvm-core/llvm-$(( LLVM_MAX_SLOT + 1 )):=
	)
	blosc? (
		dev-libs/c-blosc:=
	)
	jemalloc? (
		dev-libs/jemalloc:=
	)
	tbbmalloc? (
		>=dev-cpp/tbb-2021.9:=
	)
	log4cplus? (
		>=dev-libs/log4cplus-1.1.2:=
	)
	nanovdb? (
		cuda? (
			>=dev-util/nvidia-cuda-toolkit-12
		)
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[numpy?,${PYTHON_USEDEP}]
			>=dev-python/nanobind-2.0.0:=
			numpy? (
				>=dev-python/numpy-1.14[${PYTHON_USEDEP}]
			)
		')
	)
	utils? (
		media-libs/mesa[egl(+)]
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		media-libs/glfw
		media-libs/glu
		x11-libs/libXxf86vm
		alembic? ( media-gfx/alembic )
		jpeg? ( media-libs/libjpeg-turbo:= )
		png? ( media-libs/libpng:= )
		openexr? ( >=media-libs/openexr-3:= )
		media-libs/libglvnd
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	>=dev-build/cmake-3.16.2-r1
	app-alternatives/yacc
	app-alternatives/lex
	dev-util/patchelf
	doc? (
		app-text/doxygen
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	test? (
		dev-cpp/gtest
		dev-util/cppunit
	)
"

S_OGT="${WORKDIR}/ogt-${OGT_COMMIT}"

PATCHES=(
	"${FILESDIR}/${PN}-8.1.0-glfw-libdir.patch"
	"${FILESDIR}/${PN}-9.0.0-fix-atomic.patch"
#	"${FILESDIR}/${PN}-10.0.1-fix-linking-of-vdb_tool-with-OpenEXR.patch"
	"${FILESDIR}/${PN}-10.0.1-log4cplus-version.patch"
#	"${FILESDIR}/${PN}-11.0.0-constexpr-version.patch"
	"${FILESDIR}/${PN}-11.0.0-cmake_fixes.patch"
	"${FILESDIR}/${PN}-12.0.0-fix-typos-1995.patch"
)

QA_PRESTRIPPED="usr/lib.*/python.*/site-packages/pyopenvdb.*"

pkg_setup() {
	openvdb_pkg_setup
	use ax && llvm_pkg_setup
	use python && python-single-r1_pkg_setup
	if ! tc-is-cross-compiler && which jemalloc-confg ; then
		if jemalloc-config --cflags | grep -q -e "cfi" ; then
			ewarn "jemalloc may need rebuild if vdb_print -version stalls."
		fi
	fi
	if use cuda ; then
		if [[ -z "${CUDA_TOOLKIT_ROOT_DIR}" ]] ; then
			ewarn
			ewarn "CUDA_TOOLKIT_ROOT_DIR should be set as a per-package environmental variable"
			ewarn
			export CUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
		else
			if [[ ! -d "${CUDA_TOOLKIT_ROOT_DIR}/lib64" ]] ; then
				eerror
				eerror "${CUDA_TOOLKIT_ROOT_DIR}/lib64 is unreachable.  Fix CUDA_TOOLKIT_ROOT_DIR"
				eerror
				die
			fi
		fi
	fi

	if use test ; then
		if use opencl ; then
			if [[ "${FEATURES}" =~ "usersandbox" ]] ; then
				eerror
				eerror 'You must add FEATURES="-usersandbox" to run pass the opencl test'
				eerror
				die
			else
				einfo 'Passed: FEATURES="-usersandbox"'
			fi
		fi
	fi

}

src_prepare() {
	MULTIBUILD_VARIANTS=( install )
	use test && MULTIBUILD_VARIANTS+=( test )

	rm "cmake/Find"{OpenEXR,TBB}".cmake" || die

	if use nanovdb; then
		sed \
			-e 's#message(WARNING " - OpenVDB required to build#message(VERBOSE " - OpenVDB required to build#g' \
			-i "nanovdb/nanovdb/"*"/CMakeLists.txt" || die
	fi

	cmake_src_prepare

	if use cuda ; then
		cuda_add_sandbox -w
		cuda_src_prepare
	fi

	sed -e 's|/usr/local/bin/python|/usr/bin/python|' \
		-i "${S}"/openvdb/openvdb/python/test/TestOpenVDB.py || die

	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" doc/CMakeLists.txt || die
	sed -i -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" {,${PN}/${PN}/}CMakeLists.txt || die
	sed -i -e "s|lib/cmake|$(get_libdir)/cmake|g" cmake/OpenVDBGLFW3Setup.cmake || die
}

my_src_configure() {
	export NINJAOPTS="-j2" # prevent stall

	openvdb_src_configure

	local mycmakeargs=(
		-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
		-DCMAKE_CXX_STANDARD=17
		-DCMAKE_POLICY_DEFAULT_CMP0167="OLD"
		-DCMAKE_FIND_PACKAGE_PREFER_CONFIG="yes"
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/"

		-DCONCURRENT_MALLOC=$(usex jemalloc "Jemalloc" \
					$(usex tbbmalloc "Tbbmalloc" "None")\
		)
		-DOPENVDB_BUILD_DOCS="$(usex doc)"
		-DOPENVDB_BUILD_PYTHON_MODULE="$(usex python)"
		-DOPENVDB_BUILD_UNITTESTS="$(usex test)"
		-DOPENVDB_BUILD_VDB_LOD="$(usex utils)"
		-DOPENVDB_BUILD_VDB_PRINT="$(usex utils)"
		-DOPENVDB_BUILD_VDB_RENDER="$(usex utils)"
		-DOPENVDB_BUILD_VDB_VIEW="$(usex utils)"
		-DOPENVDB_CORE_SHARED="ON"
		-DOPENVDB_CORE_STATIC="$(usex static-libs)"
		-DOPENVDB_ENABLE_UNINSTALL="OFF"
		-DUSE_AX="$(usex ax)"
		-DOPENVDB_BUILD_HOUDINI_PLUGIN="OFF"
		# -DOPENVDB_DOXYGEN_HOUDINI="OFF"
		-DUSE_BLOSC="$(usex blosc)"
		#-DUSE_CCACHE="OFF"
		-DUSE_COLORED_OUTPUT="ON"
		-DUSE_EXR="$(usex openexr "$(usex utils)")"
		# not packaged
		-DUSE_HOUDINI="no"
		 # replaces openexr half
		-DUSE_IMATH_HALF="$(usex imath-half)"
		-DUSE_LOG4CPLUS="$(usex log4cplus)"
		-DUSE_PKGCONFIG="yes"
		-DUSE_PNG="$(usex png "$(usex utils)")"
		-DUSE_ZLIB="$(usex zlib)"
		-DUSE_PKGCONFIG=ON
		#-DUSE_VCL="$(usex vcl)"
	)

	if use ax; then
		mycmakeargs+=(
			-DOPENVDB_AX_STATIC="$(usex static-libs)"
			-DOPENVDB_DOXYGEN_AX="$(usex doc)"
			# FIXME: log4cplus init and other errors
			-DOPENVDB_BUILD_VDB_AX="ON"
			-DOPENVDB_BUILD_AX_UNITTESTS="$(usex test)" # FIXME: log4cplus init and other errors
		)
	fi

	if use nanovdb; then
		use magicavoxel && mycmakeargs+=(
			-DEOGT_SOURCE_DIR="${S_OGT}"
		)
		mycmakeargs+=(
			-DUSE_NANOVDB="ON"
			# NOTE intentional so it breaks in sandbox if files are missing
			-DNANOVDB_ALLOW_FETCHCONTENT="OFF"
			-DNANOVDB_BUILD_EXAMPLES="$(usex examples)"
			-DNANOVDB_BUILD_TOOLS="$(usex utils)"
			-DNANOVDB_BUILD_UNITTESTS="$(usex test)"
			-DNANOVDB_USE_BLOSC="$(usex blosc)"
			-DNANOVDB_USE_CUDA="$(usex cuda)"
			-DNANOVDB_USE_ZLIB="$(usex zlib)"
			-DNANOVDB_USE_TBB="$(usex tbbmalloc)"
			-DNANOVDB_USE_MAGICAVOXEL=$(usex magicavoxel)
			-DNANOVDB_USE_OPENVDB="ON"
		)
		if use cpu_flags_x86_avx || use cpu_flags_x86_sse4_2; then
			mycmakeargs+=(
				-DNANOVDB_USE_INTRINSICS="yes"
			)
		fi

		if use cuda ; then
			cuda_add_sandbox -w
			for CT in ${CUDA_TARGETS_COMPAT[@]}; do
				use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT#sm_*};"
			done
			mycmakeargs+=(
				-DCMAKE_CUDA_ARCHITECTURES="${CUDA_TARGETS%%;}"
				-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
			)
			# NOTE tbb includes immintrin.h, which breaks nvcc so we pretend they are already included
			export CUDAFLAGS="-D_AVX512BF16VLINTRIN_H_INCLUDED -D_AVX512BF16INTRIN_H_INCLUDED"
		fi

		if use utils; then
			mycmakeargs+=(
				-DOPENVDB_TOOL_USE_NANO="yes"
				-DOPENVDB_TOOL_NANO_USE_BLOSC="$(usex blosc)"
				-DOPENVDB_TOOL_NANO_USE_ZIP="$(usex zlib)"
			)
		fi
	fi

	if use python; then
		mycmakeargs+=(
			-DUSE_NUMPY="$(usex numpy)"
			-DVDB_PYTHON_INSTALL_DIRECTORY="$(python_get_sitedir)"
			-DPython_INCLUDE_DIR="$(python_get_includedir)"
		)
		use nanovdb && mycmakeargs+=(
			-DNANOVDB_BUILD_PYTHON_MODULE="ON"
			-DNANOVDB_BUILD_PYTHON_UNITTESTS="$(usex test)"
			-DNANOVDB_PYTHON_INSTALL_DIRECTORY="$(python_get_sitedir)"
		)
		use test && mycmakeargs+=(
			-DPython_EXECUTABLE="${PYTHON}"
			-DOPENVDB_BUILD_PYTHON_UNITTESTS="ON"
		)
	fi

	# options for the new vdb_tool binary
	if use utils; then
		mycmakeargs+=(
			-DBUILD_TEST="$(usex test)"
			-DOPENVDB_BUILD_VDB_AX="$(usex ax)"

			-DOPENVDB_TOOL_USE_ABC="$(usex alembic)" # Alembic
			-DOPENVDB_TOOL_USE_EXR="$(usex openexr)" # OpenEXR
			-DOPENVDB_TOOL_USE_JPG="$(usex jpeg)" # libjpeg-turbo
			-DOPENVDB_TOOL_USE_PNG="$(usex png)" # libpng
		)
	fi

	if use cpu_flags_x86_avx; then
		mycmakeargs+=( -DOPENVDB_SIMD="AVX" )
	elif use cpu_flags_x86_sse4_2; then
		mycmakeargs+=( -DOPENVDB_SIMD="SSE42" )
	fi

	if [[ "${MULTIBUILD_VARIANT}" == "test" ]]; then
		# NOTE Certain tests expect bit equality and don't set tolerance violating the C standard
		# 6.5 8)
		# A floating expression may be contracted, that is, evaluated as though it were an atomic operation,
		# thereby omitting rounding errors implied by the source code and the expression evaluation method.
		# The FP_CONTRACT pragma in <math.h> provides a way to disallow contracted expressions.
		# Otherwise, whether and how expressions are contracted is implementation-defined.
		#
		# To reproduce the upstream tests the testsuite is compiled separate with FP_CONTRACT=OFF
		append-cflags   "-ffp-contract=off"
		append-cxxflags "-ffp-contract=off"
		if use ax; then
			mycmakeargs+=(
				-DOPENVDB_AX_TEST_CMD="yes"
				-DOPENVDB_AX_TEST_CMD_DOWNLOADS="yes"
			)
		fi
	fi

	CMAKE_BUILD_TYPE=$(usex debug 'RelWithDebInfo' 'Release')
	cmake_src_configure
}

my_src_test() {
	[[ "${MULTIBUILD_VARIANT}" != "test" ]] && return

	if use ax; then
		ln -sr "${CMAKE_USE_DIR}/openvdb_ax/openvdb_ax/test" "${BUILD_DIR}/test" || die
	fi

	if use cuda; then
		cuda_add_sandbox -w
	fi

	cmake_src_test
}

my_src_install() {
	[[ "${MULTIBUILD_VARIANT}" == "test" ]] && return
	cmake_src_install
}

src_configure() {
	# -Werror=strict-aliasing
	# https://bugs.gentoo.org/926820
	# https://github.com/AcademySoftwareFoundation/openvdb/issues/1784
	append-flags -fno-strict-aliasing
	filter-lto

	multibuild_foreach_variant my_src_configure
}

src_compile() {
	multibuild_foreach_variant cmake_src_compile
}

src_test() {
	multibuild_foreach_variant my_src_test
}

src_install() {
	multibuild_foreach_variant my_src_install
}
