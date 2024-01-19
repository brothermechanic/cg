# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This version corresponds to OpenVDB 11.0.0.

inherit cmake cuda flag-o-matic

DESCRIPTION="A lightweight GPU friendly version of VDB initially targeting rendering applications."
HOMEPAGE="https://github.com/AcademySoftwareFoundation/openvdb/tree/feature/nanovdb/nanovdb"
LICENSE="MPL-2.0"
# For versioning, see
# https://github.com/AcademySoftwareFoundation/openvdb/blob/v10.0.1/nanovdb/nanovdb/NanoVDB.h#L104
SLOT="0/$(ver_cut 1-2 ${PV})"
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 sm_87 sm_89 sm_90 )
KEYWORDS="~amd64"
IUSE+="
${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
benchmark +blosc cuda debug doc examples interactive-renderer -log4cplus -magicavoxel +intrinsics
+opencl optix +opengl openexr +openvdb +system-glfw +tbb test test-renderer tools +zlib
"
REQUIRED_USE+="
	benchmark? (
		openvdb
	)
	blosc? (
		openvdb
	)
	cuda? (
		|| (
			${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
		)
	)
	interactive-renderer? (
		tools
	)
	log4cplus? (
		openvdb
	)
	magicavoxel? (
		examples
	)
	openexr? (
		openvdb
	)
	openvdb? (
		tbb
		zlib
	)
	test? (
		openvdb
		tbb
	)
	test-renderer? (
		test
	)
"
# For dependencies, see
# https://github.com/AcademySoftwareFoundation/openvdb/blob/v10.0.1/doc/dependencies.txt
EGIT_COMMIT="77f28d16114949dfbe2937aa2dae1379f6d2b653"
GH_ORG_URI="https://github.com/AcademySoftwareFoundation"
GTEST_PV="1.11.0"
OGT_COMMIT="e1743d37cf7a8128568769cf71cf598166c2cd30"
OGT_DFN="ogt-${OGT_COMMIT:0:7}.tar.gz"

DEPEND_GTEST="
	>=dev-cpp/gtest-${GTEST_PV}
"

DEPEND+="
	benchmark? (
		${DEPEND_GTEST}
	)
	blosc? (
		>=dev-libs/c-blosc-1.17
	)
	cuda? (
		|| (
			=dev-util/nvidia-cuda-toolkit-11*:=
			=dev-util/nvidia-cuda-toolkit-12*:=
		)
	)
	opencl? (
		virtual/opencl
	)
	opengl? (
		virtual/opengl
	)
	openvdb? (
		>=dev-libs/boost-1.68
		>=media-gfx/openvdb-10
		>=media-libs/openexr-3.1.5-r1
	)
	optix? (
		>=dev-libs/optix-7
	)
	tbb? (
		>=dev-cpp/tbb-2021:0=
	)
	tools? (
		>=media-libs/glfw-3.3
		media-libs/mesa[egl(+)]
		interactive-renderer? (
			system-glfw? (
				>=media-libs/glfw-3.1
			)
		)
	)
	zlib? (
		>=sys-libs/zlib-1.2.7
	)
"
RDEPEND+="
	${DEPEND}
"
BDEPEND+="
	>=dev-build/cmake-3.15
	doc? (
		>=app-doc/doxygen-1.8.8
	)
	test? (
		${DEPEND_GTEST}
		test-renderer? (
			media-gfx/imagemagick[png]
		)
	)
	|| (
		>=sys-devel/gcc-6.3.1
		>=sys-devel/clang-3.8
		>=dev-lang/icc-17
	)
"
SRC_URI="
${GH_ORG_URI}/openvdb/archive/${EGIT_COMMIT}.tar.gz
	-> ${PN}-${PV}-${EGIT_COMMIT:0:7}.tar.gz
https://github.com/jpaver/opengametools/archive/${OGT_COMMIT}.tar.gz
	-> ${OGT_DFN}
"
RESTRICT="mirror"
PATCHES_=(
	"${FILESDIR}/${PN}-32.3.3_p20211029-cmake-use-tarballs.patch"
)
S="${WORKDIR}/openvdb-${EGIT_COMMIT}/${PN}/${PN}"
S_OGT="${WORKDIR}/ogt-${OGT_COMMIT}"

pkg_setup() {
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

	if use optix ; then
		if [[ -z "${OptiX_ROOT}" ]] ; then
			ewarn
			ewarn "OptiX_ROOT should be set as a per-package environmental variable"
			ewarn
			export OptiX_ROOT="${EPREFIX}"/opt/optix
		fi
		if [[ ! -f "${OptiX_ROOT}/include/optix.h" ]] ; then
			eerror
			eerror "${OptiX_ROOT}/include/optix.h is unreachable.  Fix OptiX_ROOT"
			eerror
			die
		fi
		if [[ -z "${OptiX_INSTALL_DIR}" ]] ; then
			ewarn
			ewarn "OptiX_INSTALL_DIR should be set as a per-package environmental variable"
			ewarn
			export OptiX_INSTALL_DIR="${EPREFIX}"/opt/optix
		fi
		if [[ ! -d "${OptiX_INSTALL_DIR}/include" ]] ; then
			eerror
			eerror "${OptiX_INSTALL_DIR}/include is unreachable.  Fix OptiX_INSTALL_DIR"
			eerror
			die
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
	default
	if use tbb && has_version -b ">=dev-cpp/tbb-2021.0" ; then
		eapply "${FILESDIR}/${PN}-32.3.3_p20211029-onetbb-split-header-location.patch"
		sed -i -e "s|__NANOVDB_USE_ONETBB__|1|g" "${S}/util/Range.h" || die
	fi
	cmake_src_prepare
	if use cuda ; then
		cuda_add_sandbox -w
		cuda_src_prepare
	fi
}

src_configure()
{
	export NINJAOPTS="-j2" # Prevent counterproductive swapping.  Observed a 3 GiB process.
	ewarn "Switch to clang + lld if it takes more than 1.5 hrs to build."
	# Completed build in 1 hr and 3 min in 32.x, but noticible stall with gcc.
	if use opencl ; then
		append-cppflags -DCL_TARGET_OPENCL_VERSION=120
	fi

	CMAKE_BUILD_TYPE=$(usex debug 'Debug' 'Release')

	local mycmakeargs=(
		-DNANOVDB_ALLOW_FETCHCONTENT=OFF
		-DNANOVDB_BUILD_BENCHMARK=$(usex benchmark)
		-DNANOVDB_BUILD_EXAMPLES=$(usex examples)
		-DNANOVDB_BUILD_UNITTESTS=$(usex test)
		-DNANOVDB_BUILD_DOCS=$(usex doc)
		-DNANOVDB_BUILD_TOOLS=$(usex tools)
		-DNANOVDB_GTEST=$(usex test)
		-DNANOVDB_USE_BLOSC=$(usex blosc)
		-DNANOVDB_USE_CUDA=$(usex cuda)
		-DNANOVDB_USE_MAGICAVOXEL=$(usex magicavoxel)
		-DNANOVDB_USE_INTRINSICS=$(usex intrinsics)
		-DNANOVDB_USE_OPENCL=$(usex opencl)
		-DNANOVDB_USE_OPENGL=$(usex opengl)
		-DNANOVDB_USE_OPENVDB=$(usex openvdb)
		-DNANOVDB_USE_OPTIX=$(usex optix)
		-DNANOVDB_USE_TBB=$(usex tbb)
		-DNANOVDB_USE_ZLIB=$(usex zlib)
		-DUSE_BLOSC=$(usex blosc)
		-DUSE_EXR=$(usex openexr)
		-DUSE_LOG4CPLUS=$(usex log4cplus)
	)

	if use cuda ; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT#sm_*};"
		done
		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES="${CUDA_TARGETS%%;}"
			-DCMAKE_CUDA_FLAGS="$(cuda_gccdir -f | tr -d \")"
		)
	fi

	if use magicavoxel ; then
		mycmakeargs+=(
			-DEOGT_SOURCE_DIR="${S_OGT}"
		)
	fi

	cmake_src_configure
}

core_tests()
{
	# keep in sync with ci/test_core.sh
# Tests for nanovdb-25.0.0_pre20200924
# Date: Wed Jun 30 10:40:56 PM PDT 2021 (Unix time: 1625118056)

#testOpenVDB result:
#[==========] 17 tests from 1 test suite ran. (5545 ms total)
#[  PASSED  ] 17 tests.

#testNanoVDB results:
#[==========] 39 tests from 1 test suite ran. (1888 ms total)
#[  PASSED  ] 39 tests.

	cd "${BUILD_DIR}" || die
	einfo "Running core tests"
	cmake_src_test
	einfo "Running testOpenVDB"
	unittest/testOpenVDB || die
	echo
	einfo "Running testNanoVDB"
	unittest/testNanoVDB || die
	echo
}

video_card_sandbox_predict()
{
    local d
	for d in /dev/dri/card*; do
    	[[ -s "${d}" ]] && addpredict "${d}"
	done
}

render_tests()
{
	einfo "Running render tests"
	# keep in sync with nanovdb/ci/test_render.sh
	# make gold image.
	local out_path="$(pwd)/out"
	mkdir -p "${out_path}" || die
	cmd/nanovdb_viewer -b -o "${out_path}/gold" -p host-mt --count 1 --turntable || die
	mogrify -format png "${out_path}/gold.0000.pfm" || die

	video_card_sandbox_predict
	if use cuda ; then
		cmd="$(pwd)/cmd/nanovdb_viewer -b --gold ${out_path}/gold -o ${out_path}/test-cuda -p cuda -n 1 --turntable"
		einfo "Running ${cmd}"
		${cmd} || die
	fi
	cmd="cmd/nanovdb_viewer -b --gold ${out_path}/gold -o ${out_path}/test-c99 -p host-c99 -n 1 --turntable"
	einfo "Running ${cmd}"
	${cmd} || die
	if false && use opengl ; then
		# opengl is not accessible
		cmd="$(pwd)/cmd/nanovdb_viewer -b --gold ${out_path}/gold -o ${out_path}/test-glsl -p glsl -n 1 --turntable"
		einfo "Running ${cmd}"
		${cmd} || die
	fi
	# No platform TBB for viewer
	if use opencl ; then
		cmd="$(pwd)/cmd/nanovdb_viewer -b --gold ${out_path}/gold -o ${out_path}/test-opencl -p opencl -n 1 --turntable"
		einfo "Running ${cmd}"
		${cmd} || die
	fi
	if use optix ; then
		cmd="$(pwd)/cmd/nanovdb_viewer -b --gold ${out_path}/gold -o ${out_path}/test-optix -p optix -n 1 --turntable"
		einfo "Running ${cmd}"
		${cmd} || die
	fi
}

src_test()
{
	core_tests
	use test-renderer && render_tests
}

src_install()
{
	cmake_src_install
	cd "${S}" || die
	dodoc Readme.md
	cd "${S}/../.." || die
	docinto licenses
	dodoc LICENSE
}

