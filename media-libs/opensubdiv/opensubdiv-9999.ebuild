# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CMAKE_MAKEFILE_GENERATOR=emake
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 )

inherit cmake cuda toolchain-funcs

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
IUSE="X cuda doc examples opencl opengl openmp ptex tbb test tutorials ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"
RESTRICT="
	mirror
	!test? ( test )
"

RDEPEND="
	media-libs/glew:=
	media-libs/glfw:=
	X? ( x11-libs/libX11 )
	cuda? ( dev-util/nvidia-cuda-toolkit:* )
	opencl? ( virtual/opencl )
	opengl? ( media-libs/libglvnd[X?] )
	ptex? ( media-libs/ptex )
"
DEPEND="
	${RDEPEND}
	tbb? ( dev-cpp/tbb:= )
"

REQUIRED_USE="
	|| ( ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_} )
"

PATCHES=(
	"${FILESDIR}/${PN}-3.3.0-use-gnuinstalldirs.patch"
	"${FILESDIR}/${PN}-3.4.3-install-tutorials-into-bin.patch"
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
	use cuda && cuda_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	# GLTESTS are disabled as portage is unable to open a display during test phase
	# TODO: virtx work?
	local mycmakeargs=(
		-DGLEW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
		-DGLFW_LOCATION="${ESYSROOT}/usr/$(get_libdir)"
		-DNO_CLEW=ON
		-DNO_GLFW_X11=$(usex !X)
		-DNO_CUDA=$(usex !cuda)
		-DNO_DOC=$(usex !doc)
		-DNO_EXAMPLES=$(usex !examples)
		-DNO_GLTESTS=ON
		-DNO_OMP=$(usex !openmp)
		-DNO_OPENCL=$(usex !opencl)
		-DNO_OPENGL=$(usex !opengl)
		-DNO_PTEX=$(usex !ptex)
		-DNO_REGRESSION=$(usex !test)
		-DNO_TBB=$(usex !tbb)
		-DNO_TESTS=$(usex !test)
		-DNO_TUTORIALS=$(usex !tutorials)
		-DNO_METAL=ON
		-DNO_DX=ON
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
			-DCUDA_NVCC_FLAGS="${NVCCFLAGS} ${CUDA_TARGETS%% }"
		)
	fi

	cmake_src_configure
}
