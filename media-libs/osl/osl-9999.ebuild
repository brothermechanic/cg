# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit cmake cuda flag-o-matic llvm multilib-minimal python-single-r1 toolchain-funcs

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"
if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage"
	EGIT_BRANCH="main"
	KEYWORDS=""
	# Check this on updates
	LLVM_MAX_SLOT=17
	LLVM_SLOTS=( 16 17 )
else
	SRC_URI="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	PATCHES+=(
		#"${FILESDIR}/osl-1.12.13.0-llvm-17.patch"
		"${FILESDIR}/osl-1.12.13.0-cuda-noinline-fix.patch"
	)
	KEYWORDS="~amd64 ~x86 ~arm ~arm64"
	S="${WORKDIR}/OpenShadingLanguage-${PV}"

	# Check this on updates
	LLVM_MAX_SLOT=15
	LLVM_SLOTS=( 9 10 11 12 13 14 15 )
fi

SLOT="0/$(ver_cut 1-2 ${PV})"

LICENSE="BSD"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 )

IUSE="doc debug optix partio python plugins qt5 qt6 static-libs test wayland X ${CPU_FEATURES[@]%:*} ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"
RESTRICT="
	!test (test)
	mirror
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	optix? (
		^^ ( ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_} )
	)
	?? ( qt5 qt6 )
	qt5? ( || ( wayland X ) )
	qt6? ( || ( wayland X ) )
"

RDEPEND="
	>=media-libs/openexr-3.1.0:=
	$(python_gen_cond_dep '
		>=media-libs/openimageio-2.4.12.0:=[${PYTHON_SINGLE_USEDEP}]
		<media-libs/openimageio-2.6:=[${PYTHON_SINGLE_USEDEP}]
	')
	>=dev-libs/boost-1.55:=[${MULTILIB_USEDEP}]
	>=dev-libs/pugixml-1.8[${MULTILIB_USEDEP}]
	dev-libs/libfmt[${MULTILIB_USEDEP}]
	<sys-devel/llvm-$((${LLVM_MAX_SLOT} + 1)):=
	<sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):=
	sys-libs/zlib:=[${MULTILIB_USEDEP}]
	optix? (
		$(python_gen_cond_dep '
			>=media-libs/openimageio-1.8:=[${PYTHON_SINGLE_USEDEP}]
		')
		>=dev-util/nvidia-cuda-toolkit-9:=
		>=dev-libs/optix-5.1
	)
	partio? (
		>=media-libs/partio-1.13.2
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-python/pybind11-2.4.2[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5[wayland?,X?]
		dev-qt/qtwidgets:5[X?]
	)
	qt6? (
		dev-qt/qtbase:6[gui,wayland?,widgets,X?]
		wayland? (
			dev-qt/qtdeclarative:6[opengl]
			dev-qt/qtwayland:6
		)
	)
	virtual/libc
"

DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/cmake-3.12
	>=dev-util/pkgconf-1.3.7[${MULTILIB_USEDEP},pkg-config(+)]
	>=sys-devel/bison-2.7
	>=sys-devel/flex-2.5.35[${MULTILIB_USEDEP}]
"

PATCHES+=(
	"${FILESDIR}/osl-1.12.13.0-change-ci-test.bash.patch"
	"${FILESDIR}/osl-1.12.14.0-lld-fix-linking.patch"
)

get_lib_type() {
	use static-libs && echo "static"
	echo "shared"
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
	llvm_pkg_setup
}

src_prepare() {
	if ! use test ; then
		sed -i -e "s|osl_add_all_tests|#osl_add_all_tests|g" \
			"CMakeLists.txt" || die
	fi

	# optix 7.4 build fix
	if use optix && has_version ">=dev-libs/optix-7.4"; then
		sed -i -e 's/OPTIX_COMPILE_DEBUG_LEVEL_LINEINFO/OPTIX_COMPILE_DEBUG_LEVEL_MINIMAL/g' src/testshade/optixgridrender.cpp src/testrender/optixraytracer.cpp || die
		cuda_src_prepare
	fi
	sed -e 's/DESTINATION cmake/DESTINATION "${OSL_CONFIG_INSTALL_DIR}"/g' \
		-re '/install \(FILES src\/build-scripts\/serialize-bc\.py/{:a;N;/PERMISSIONS \$\{PERMISSION_FLAGS\}\)/!ba};/DESTINATION build-scripts/d' \
		-i CMakeLists.txt || die "Sed failed."
	cmake_src_prepare
}

src_configure() {
	configure_abi() {
		local llvm_slot
		for llvm_slot in ${LLVM_SLOTS[@]} ; do
			if has_version -b =sys-devel/llvm-${llvm_slot} ; then
				einfo "Linking with LLVM-${llvm_slot}"
				break
			fi
		done

		local lib_type
		for lib_type in $(get_lib_type) ; do
			export CMAKE_USE_DIR="${S}"
			export BUILD_DIR="${S}-${MULTILIB_ABI_FLAG}.${ABI}_${lib_type}_build"
			cd "${CMAKE_USE_DIR}" || die

			local cpufeature
			local mysimd=()
			for cpufeature in "${CPU_FEATURES[@]}"; do
				use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
			done

			use debug && CMAKE_BUILD_TYPE=Debug || CMAKE_BUILD_TYPE=Release

			# If no CPU SIMDs were used, completely disable them
			[[ -z ${mysimd} ]] && mysimd=("0")

			# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
			# Even if there are no SIMD features selected, it seems like the code will turn on NEON support if it is available.
			use arm64 && append-flags -flax-vector-conversions

			filter-flags -no-opaque-pointers

			local gcc="$(tc-getCC)"
			local mycmakeargs=(
				-DCMAKE_CXX_STANDARD=17
				-DLLVM_ROOT="${EPREFIX}/usr/lib/llvm/${llvm_slot}"
				-DCMAKE_INSTALL_BINDIR="${EPREFIX}/usr/$(get_libdir)/osl/bin"
				-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
				-DINSTALL_DOCS=$(usex doc)
				-DLLVM_STATIC=OFF
				-DOSL_SHADER_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/shaders"
				-DBUILD_SHARED_LIBS=ON
				-DOSL_BUILD_TESTS=$(usex test)
				-DOSL_BUILD_PLUGINS=$(usex plugins)
				-DOSL_PTX_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/ptx"
				-DSTOP_ON_WARNING=OFF
				-DUSE_CCACHE=OFF
				-DUSE_CUDA=$(usex optix)
				-DUSE_OPTIX=$(usex optix)
				-DUSE_PARTIO=$(usex partio)
				-DUSE_QT=$(usex qt6 ON $(usex qt5 ON OFF))
				-DUSE_PYTHON=$(usex python)
				-DPYTHON_VERSION="${EPYTHON/python}"
				-DUSE_SIMD="$(IFS=","; echo "${mysimd[*]}")"
			)

			if use optix; then
				for CT in ${CUDA_TARGETS_COMPAT[@]}; do
					use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT};"
				done

				mycmakeargs+=(
					-DCUDA_TARGET_ARCH="${CUDA_TARGETS%%;}"
					-DCUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
				)
			fi
			cmake_src_configure
		done
	}
	multilib_foreach_abi configure_abi
}

src_compile() {
	compile_abi() {
		local lib_type
		for lib_type in $(get_lib_type) ; do
			export CMAKE_USE_DIR="${S}"
			export BUILD_DIR="${S}-${MULTILIB_ABI_FLAG}.${ABI}_${lib_type}_build"
			cd "${BUILD_DIR}" || die
			cmake_src_compile
		done
	}
	multilib_foreach_abi compile_abi
}

src_test() {
	# TODO: investigate failures
	local myctestargs=(
		-E "(osl-imageio|osl-imageio.opt|render-background|render-bumptest|render-mx-furnace-burley-diffuse|render-mx-furnace-sheen|render-mx-burley-diffuse|render-mx-conductor|render-mx-generalized-schlick|render-mx-generalized-schlick-glass|render-microfacet|render-oren-nayar|render-uv|render-veachmis|render-ward|render-raytypes.opt|color|color.opt|example-deformer)"
	)

	cmake_src_test
}

src_install() {
	install_abi() {
		local lib_type
		for lib_type in $(get_lib_type) ; do
			export CMAKE_USE_DIR="${S}"
			export BUILD_DIR="${S}-${MULTILIB_ABI_FLAG}.${ABI}_${lib_type}_build"
			cd "${BUILD_DIR}" || die
			cmake_src_install
		done
		if multilib_is_native_abi ; then
			dosym /usr/$(get_libdir)/osl/bin/oslc /usr/bin/oslc
			dosym /usr/$(get_libdir)/osl/bin/oslinfo /usr/bin/oslinfo
		fi
		multilib_check_headers
	}
	multilib_foreach_abi install_abi
}

