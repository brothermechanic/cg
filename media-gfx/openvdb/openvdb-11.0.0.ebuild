# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

OPENVDB_COMPAT=( {7..11} )
PYTHON_COMPAT=( python3_{10..12} )
inherit cmake cuda flag-o-matic llvm python-single-r1 toolchain-funcs openvdb

DESCRIPTION="Library for the efficient manipulation of volumetric data"
LICENSE="MPL-2.0"
HOMEPAGE="https://www.openvdb.org"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
SLOT="0/$(ver_cut 1-2)"
LLVM_SLOTS=( 16 17 )
X86_CPU_FLAGS=( avx sse4_2 )
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 sm_87 sm_89 sm_90 )
IUSE="
${X86_CPU_FLAGS[@]/#/cpu_flags_x86_}
${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
ax +blosc benchmark clang cuda debug doc -imath-half examples jemalloc
-log4cplus nanovdb numpy python +static-libs tbbmalloc openexr png test
-vdb_lod +vdb_print -vdb_render -vdb_view zlib
"
VDB_UTILS="
	vdb_lod
	vdb_print
	vdb_render
	vdb_view
"
# For abi versions, see https://github.com/AcademySoftwareFoundation/openvdb/blob/v10.0.1/CMakeLists.txt#L256
REQUIRED_USE="
	${OPENVDB_REQUIRED_USE}
	?? (
		jemalloc
		tbbmalloc
	)
	cuda? (
		|| (
			${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
		)
	)
	jemalloc? (
		|| (
			${VDB_UTILS}
			test
		)
	)
	nanovdb? (
		cuda
	)
	numpy? (
		python
	)
	python? (
		${PYTHON_REQUIRED_USE}
	)
	openexr? (
		|| (
			${VDB_UTILS}
		)
	)
	png? (
		|| (
			${VDB_UTILS}
		)
	)
	ax? ( zlib )
"

RDEPEND+="
	>=dev-libs/boost-1.66:=
	zlib? ( >=sys-libs/zlib-1.2.7:= )
	ax? (
		<sys-devel/llvm-15:=
	)
	blosc? (
		>=dev-libs/c-blosc-1.17:=
	)
	jemalloc? (
		dev-libs/jemalloc:=
	)
	log4cplus? (
		>=dev-libs/log4cplus-1.1.2:=
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.68:=[numpy?,python?,${PYTHON_USEDEP}]
			numpy? (
				>=dev-python/numpy-1.14[${PYTHON_USEDEP}]
			)
		')
	)
	vdb_view? (
		>=media-libs/glfw-3.1
		>=media-libs/glfw-3.3
		media-libs/glu
		media-libs/mesa[egl(+)]
		virtual/opengl
		x11-libs/libX11
		x11-libs/libXcursor
		x11-libs/libXi
		x11-libs/libXinerama
		x11-libs/libXrandr
		x11-libs/libXxf86vm
	)
	openexr? (
		>=media-libs/openexr-3.1.5-r1
	)
	>=dev-cpp/tbb-2021.9:=
"
DEPEND+="
	${RDEPEND}
"
BDEPEND+="
	>=dev-build/cmake-3.16.2-r1
	>=sys-devel/bison-3
	>=sys-devel/flex-2.6
	dev-util/patchelf
	virtual/pkgconfig
	doc? (
		>=app-doc/doxygen-1.8.8
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	test? (
		>=dev-cpp/gtest-1.10
		>=dev-util/cppunit-1.10
	)
	|| (
		>=sys-devel/gcc-6.3.1
		(
			<sys-devel/clang-17
			>=sys-devel/clang-3.8
		)
		>=dev-lang/icc-17
	)
"
PDEPEND="
	nanovdb? (
		>=media-gfx/nanovdb-32[cuda?,openvdb]
	)
"

SRC_URI="
https://github.com/AcademySoftwareFoundation/${PN}/archive/v${PV}.tar.gz
	-> ${P}.tar.gz
"
PATCHES=(
#	"${FILESDIR}/${PN}-7.1.0-0001-Fix-multilib-header-source.patch"
	"${FILESDIR}/${PN}-8.1.0-glfw-libdir.patch"
	"${FILESDIR}/${PN}-9.0.0-fix-atomic.patch"
#	"${FILESDIR}/${PN}-10.0.1-fix-linking-of-vdb_tool-with-OpenEXR.patch"
	"${FILESDIR}/${PN}-10.0.1-drop-failing-tests.patch"
	"${FILESDIR}/${PN}-10.0.1-log4cplus-version.patch"
)
RESTRICT="
	mirror
	!test? ( test )
"

QA_PRESTRIPPED="usr/lib.*/python.*/site-packages/pyopenvdb.*"

pkg_setup() {
	openvdb_pkg_setup
	use python && python-single-r1_pkg_setup
	if ! tc-is-cross-compiler && which jemalloc-confg ; then
		if jemalloc-config --cflags | grep -q -e "cfi" ; then
			ewarn "jemalloc may need rebuild if vdb_print -version stalls."
		fi
	fi
	use ax && llvm_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	sed -i -e "s|DESTINATION doc|DESTINATION share/doc/${P}|g" doc/CMakeLists.txt || die
	sed -i -e "s|DESTINATION lib|DESTINATION $(get_libdir)|g" {,${PN}/${PN}/}CMakeLists.txt || die
	sed -i -e "s|lib/cmake|$(get_libdir)/cmake|g" cmake/OpenVDBGLFW3Setup.cmake || die
}

check_clang() {
	local found=0
	local s
	for s in ${LLVM_SLOTS[@]} ; do
		if has_version "sys-devel/clang:${s}" ; then
			found=1
			export CC="${CHOST}-clang-${s}"
			export CXX="${CHOST}-clang++-${s}"
			break
		fi
	done
	if (( ${found} == 0 )) ; then
		eerror
		eerror "${PN} requires either clang ${LLVM_SLOTS[@]}"
		eerror
		eerror "Either use GCC or install and use one of those clang slots."
		eerror
		die
	fi
	clang --version || die
}

src_configure() {
	use clang && check_clang
	export NINJAOPTS="-j2" # prevent stall

	openvdb_src_configure

	CMAKE_BUILD_TYPE=$(usex debug 'Debug' 'Release')

	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}/"
		-DCONCURRENT_MALLOC=$(usex jemalloc "Jemalloc" \
					$(usex tbbmalloc "Tbbmalloc" "None")\
		)
		-DOPENVDB_BUILD_BINARIES=$(usex vdb_lod ON \
			$(usex vdb_print ON \
				$(usex vdb_render ON \
					$(usex vdb_view ON OFF))\
			)\
		)
		-DOPENVDB_BUILD_DOCS=$(usex doc)
		-DOPENVDB_BUILD_PYTHON_MODULE=$(usex python)
		-DOPENVDB_BUILD_UNITTESTS=$(usex test)
		-DOPENVDB_BUILD_VDB_LOD=$(usex vdb_lod)
		-DOPENVDB_BUILD_VDB_PRINT=$(usex vdb_print)
		-DOPENVDB_BUILD_VDB_RENDER=$(usex vdb_render)
		-DOPENVDB_BUILD_VDB_VIEW=$(usex vdb_view)
		-DOPENVDB_CORE_SHARED=ON
		-DOPENVDB_CORE_STATIC=$(usex static-libs)
		-DOPENVDB_ENABLE_RPATH=OFF
		-DUSE_BLOSC=$(usex blosc)
		-DUSE_CCACHE=OFF
		-DUSE_COLORED_OUTPUT=ON
		-DUSE_EXR=$(usex openexr)
		-DUSE_PNG=$(usex png)
		-DUSE_IMATH_HALF=$(usex imath-half)
		-DUSE_LOG4CPLUS=$(usex log4cplus)
		-DUSE_ZLIB=$(usex zlib)
		-DUSE_PKGCONFIG=ON
	)

	if use ax; then
		mycmakeargs+=(
			-DOPENVDB_AX_STATIC=$(usex static-libs)
			# FIXME: log4cplus init and other errors
			-DOPENVDB_BUILD_AX_UNITTESTS=OFF
			-DOPENVDB_BUILD_VDB_AX=ON
		)
	fi

	if use cuda ; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT#sm_*};"
		done
		mycmakeargs=(
			append_cppflags CMAKE_CUDA_ARCHITECTURES="${CUDA_TARGETS%%;}"
			append_cppflags CMAKE_CUDA_FLAGS="-ccbin=$(cuda_gccdir)"
		)
	fi

	if use python; then
		mycmakeargs+=(
			-DPYOPENVDB_INSTALL_DIRECTORY="$(python_get_sitedir)"
			-DPython_EXECUTABLE="${PYTHON}"
			-DPython_INCLUDE_DIR="$(python_get_includedir)"
			-DUSE_NUMPY=$(usex numpy)
		)
	fi

	if use cpu_flags_x86_avx; then
		mycmakeargs+=( -DOPENVDB_SIMD=AVX )
	elif use cpu_flags_x86_sse4_2; then
		mycmakeargs+=( -DOPENVDB_SIMD=SSE42 )
	fi

	cmake_src_configure
}

src_install()
{
	cmake_src_install
	dodoc README.md
	docinto licenses
	dodoc LICENSE openvdb/openvdb/COPYRIGHT
}
