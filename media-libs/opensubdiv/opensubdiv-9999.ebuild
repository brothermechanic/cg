# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 )

inherit cmake cuda flag-o-matic python-any-r1 toolchain-funcs virtualx

MY_PV="$(ver_rs "1-3" '_')"

DESCRIPTION="An Open-Source subdivision surface library"
HOMEPAGE="https://graphics.pixar.com/opensubdiv/docs/intro.html"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/PixarAnimationStudios/OpenSubdiv"
	EGIT_BRANCH="release"
	KEYWORDS=""
else
	SRC_URI="https://github.com/PixarAnimationStudios/OpenSubdiv/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
fi

S="${WORKDIR}/OpenSubdiv-${MY_PV}"

# Modfied Apache-2.0 license, where section 6 has been replaced.
# See for example CMakeLists.txt for details.
LICENSE="Apache-2.0"
SLOT="0"
IUSE="X cuda doc examples +glew +glfw opencl opengl openmp ptex python tbb test tutorials ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"
RESTRICT="
	mirror
	!test? ( test )
"
REQUIRED_USE="
	|| ( opencl opengl )
"

BDEPEND="
	doc? (
		app-text/doxygen
		dev-python/docutils
	)
	python? ( ${PYTHON_DEPS} )
"

RDEPEND="
	opengl? (
		media-libs/libglvnd[X?]
		glew? (
			media-libs/glew:=
		)
		glfw? (
			media-libs/glfw:=
			X? (
				x11-libs/libX11
				x11-libs/libXcursor
				x11-libs/libXi
				x11-libs/libXinerama
				x11-libs/libXrandr
				x11-libs/libXxf86vm
			)
		)
	)
	opencl? ( virtual/opencl )
	openmp? ( || (
		sys-devel/gcc:*[openmp]
		sys-libs/libomp
	) )
	ptex? ( media-libs/ptex )
	tbb? ( dev-cpp/tbb:= )
"

# CUDA_RUNTIME is statically linked
DEPEND="
	${RDEPEND}
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
"

PATCHES=(
	"${FILESDIR}/${PN}-3.6.0-use-gnuinstalldirs.patch"
	"${FILESDIR}/${PN}-3.6.0-cudaflags.patch"
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_prepare() {
	cmake_src_prepare
	if [[ "3.4 3.5" =~ "$(ver_cut 1-2)" ]]; then
		eapply "${FILESDIR}/${PN}-3.4.4-add-CUDA11-compatibility.patch"
		eapply "${FILESDIR}/${PN}-3.4.4-tbb-2021.patch"
	fi

	sed \
		-e "/install(/s/^/#DONOTINSTALL /g" \
		-i \
			regression/*/CMakeLists.txt \
			tools/stringify/CMakeLists.txt \
		|| die

	sed \
		-e "/install( TARGETS osd_static_[cg]pu/s/^/#DONOTINSTALL /g" \
		-i \
			opensubdiv/CMakeLists.txt \
		|| die

	use cuda && cuda_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	local mycmakeargs=(
		-DCMAKE_INSTALL_BINDIR="share/${PN}/bin"
		-DNO_DOC="$(usex !doc)"
		-DNO_EXAMPLES="$(usex !examples)"
		-DNO_TUTORIALS="$(usex !tutorials)"
		-DNO_REGRESSION="$(usex !test)"
		-DNO_TESTS="$(usex !test)"

		-DNO_PTEX="$(usex !ptex)"

		# GUI
		-DNO_OPENGL="$(usex !opengl)"
		-DNO_CUDA="$(usex !cuda)"
		-DNO_OMP="$(usex !openmp)"
		-DNO_TBB="$(usex !tbb)"
		-DNO_OPENCL="$(usex !opencl)"
		-DNO_MACOS_FRAMEWORK="yes"
		-DNO_METAL="yes"
		-DNO_DX="yes"
	)

	if use cuda; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="--gpu-architecture compute_${CT#sm_*} "
		done
		( use cuda_targets_sm_30 || use cuda_targets_sm_35 ) && mycmakeargs+=(
			-DCUDA_ENABLE_DEPRECATED=1
		)
		mycmakeargs+=(
			-DOSD_CUDA_NVCC_FLAGS=""
			-DCUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
			-DCUDA_NVCC_FLAGS="-forward-unknown-opts ${NVCCFLAGS} ${CUDA_TARGETS%% }"
		)
	fi

	if use opencl; then
		mycmakeargs+=(
			# not packaged https://github.com/martijnberger/clew
			-DNO_CLEW="yes"
		)
	fi

	if use opengl; then
		mycmakeargs+=(
			-DNO_GLTESTS="$(usex !test)"
			-DNO_GLEW="$(usex !glew)"
			-DNO_GLFW="$(usex !glfw)"
		)
		if use glew; then
			mycmakeargs+=(
				-DGLEW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
			)
		fi
		if use glfw; then
			mycmakeargs+=(
				-DGLFW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
				-DNO_GLFW_X11="$(usex !X)"
			)
		fi
	fi

	if use ptex; then
		mycmakeargs+=(
			-DPTEX_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
		)
	fi

	if ! use python; then
		mycmakeargs+=(
			-DCMAKE_DISABLE_FIND_PACKAGE_Python="yes"
		)
	fi

	cmake_src_configure
}

src_test() {
	CMAKE_SKIP_TESTS=(
		# Fails due to for CL & CUDA kernels, works outside
		"glImaging"
	)

	# "far_tutorial_1_2 breaks with gcc and > -O1"
	tc-is-gcc && is-flagq '-O@(2|3|fast)' && CMAKE_SKIP_TESTS+=( "far_tutorial_1_2" )

	use cuda && cuda_add_sandbox -w

	virtx cmake_src_test

	local KERNELS=( CPU )
	use openmp && KERNELS+=( OPENMP )
	use tbb && KERNELS+=( TBB )

	# use cuda && KERNELS+=( CUDA )
	# use opencl && KERNELS+=( CL )

	use opengl && use X && KERNELS+=( XFB )
	use opengl && KERNELS+=( GLSL )

	virtx "${BUILD_DIR}/bin/glImaging" -w test -l 3 -s 256 256 -a -k "$(IFS=","; echo "${KERNELS[*]}")"
}
