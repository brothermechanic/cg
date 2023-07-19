# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

# Check this on updates
LLVM_MAX_SLOT=15

inherit cmake cuda flag-o-matic llvm toolchain-funcs python-single-r1

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"
SRC_URI="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenShadingLanguage-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
CUDA_ARCHS="sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86"

IUSE="doc optix partio qt5 test ${CPU_FEATURES[@]%:*} ${CUDA_ARCHS} python"
RESTRICT="
	!test (test)
	mirror
"
REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	optix? (
		^^ ( ${CUDA_ARCHS} )
	)
"

RDEPEND="
	dev-libs/boost:=
	dev-libs/pugixml
	>=media-libs/openexr-3:0=
	>=media-libs/openimageio-2.3.12.0:=
	<sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):=
	sys-libs/zlib:=
	optix? (
		dev-util/nvidia-cuda-toolkit:=
		>=dev-libs/optix-7.4.0
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
	partio? ( media-libs/partio )
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"

DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

PATCHES=(
	${FILESDIR}/osl-1.12.12.0-llvm-16.patch
)

llvm_check_deps() {
	has_version -r "sys-devel/clang:${LLVM_SLOT}"
}

pkg_setup() {
	llvm_pkg_setup

	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	# optix 7.4 build fix
	if use optix; then
		sed -i -e 's/OPTIX_COMPILE_DEBUG_LEVEL_LINEINFO/OPTIX_COMPILE_DEBUG_LEVEL_MINIMAL/g' src/testshade/optixgridrender.cpp src/testrender/optixraytracer.cpp || die
		cuda_src_prepare
	fi
}

src_configure() {
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	CMAKE_BUILD_TYPE=Release

	# If no CPU SIMDs were used, completely disable them
	[[ -z ${mysimd} ]] && mysimd=("0")

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	# Even if there are no SIMD features selected, it seems like the code will turn on NEON support if it is available.
	use arm64 && append-flags -flax-vector-conversions

	local gcc="$(tc-getCC)"
	local mycmakeargs=(
		-DUSE_OPTIX=$(usex optix)
		-DCMAKE_CXX_STANDARD=17
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DINSTALL_DOCS=$(usex doc)
		-DUSE_CCACHE=OFF
		-DLLVM_STATIC=OFF
		-DOSL_BUILD_TESTS=$(usex test)
		-DOSL_SHADER_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/shaders"
		-DOSL_PTX_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/ptx"
		-DSTOP_ON_WARNING=OFF
		-DUSE_PARTIO=$(usex partio)
		-DUSE_QT=$(usex qt5)
		-DUSE_PYTHON=$(usex python)
		-DPYTHON_VERSION="${EPYTHON/python}"
		-DUSE_SIMD="$(IFS=","; echo "${mysimd[*]}")"
	)

	if use optix; then
		for CA in ${CUDA_ARCHS}; do
			use ${CA} && mycmakeargs+=(	-DCUDA_TARGET_ARCH="${CA}" ) && break
		done
	fi
	cmake_src_configure
}

src_test() {
	# TODO: investigate failures
	local myctestargs=(
		-E "(osl-imageio|osl-imageio.opt|render-background|render-bumptest|render-mx-furnace-burley-diffuse|render-mx-furnace-sheen|render-mx-burley-diffuse|render-mx-conductor|render-mx-generalized-schlick|render-mx-generalized-schlick-glass|render-microfacet|render-oren-nayar|render-uv|render-veachmis|render-ward|render-raytypes.opt|color|color.opt|example-deformer)"
	)

	cmake_src_test
}
