# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# keep in sync with blender
PYTHON_COMPAT=( python3_{11..13} )

# Check this on updates
OPENVDB_COMPAT=( {7..12} )

inherit cmake cuda flag-o-matic multilib-minimal python-single-r1 toolchain-funcs openvdb

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl https://www.imageworks.com/technology/opensource https://github.com/AcademySoftwareFoundation/OpenShadingLanguage"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage.git"
	EGIT_BRANCH="main"
	KEYWORDS=""
	SLOT="0/1.14"
else
	MY_PV=${PV//_/-}
	SRC_URI="https://github.com/AcademySoftwareFoundation/OpenShadingLanguage/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~ppc64"
	S="${WORKDIR}/OpenShadingLanguage-${MY_PV}"
	SLOT="0/$(ver_cut 1-2 ${PV})"
fi

if [[ "${PV}" =~ "1.13" ]]; then
	PATCHES+=(
		"${FILESDIR}/osl-1.13.6.0-lld-fix-linking.patch"
	)
	# Check this on updates
	LLVM_COMPAT=( {17..19} )
else
	LLVM_COMPAT=( {18..20} )
fi
inherit llvm-r1

LICENSE="BSD"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )
CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 )

IUSE="doc debug cuda gui nofma partio python plugins openvdb optix qt6 static-libs test wayland X ${CPU_FEATURES[@]%:*} ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"
RESTRICT="
	!test (test)
	mirror
"

REQUIRED_USE="
	${PYTHON_REQUIRED_USE}
	cuda? (
		^^ ( ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_} )
	)
	gui? (
		|| ( wayland X )
	)
	optix? ( cuda )
	test? ( optix )
"

RDEPEND="
    $(llvm_gen_dep '
      llvm-core/clang:${LLVM_SLOT}=
      llvm-core/llvm:${LLVM_SLOT}=
    ')
	>=dev-libs/boost-1.55:=[${MULTILIB_USEDEP}]
	>=dev-libs/pugixml-1.8[${MULTILIB_USEDEP}]
	>=media-libs/openexr-3.1.0:=
	openvdb? ( >=media-gfx/openvdb-9.0.0:=[${OPENVDB_SINGLE_USEDEP},cuda?] )
	$(python_gen_cond_dep '
		>=media-libs/openimageio-2.4.12.0:=[${PYTHON_SINGLE_USEDEP}]
		<media-libs/openimageio-3.1:=[${PYTHON_SINGLE_USEDEP}]
	')
	dev-libs/libfmt[${MULTILIB_USEDEP}]
	sys-libs/zlib:=[${MULTILIB_USEDEP}]
	cuda? (
		$(python_gen_cond_dep '
			>=media-libs/openimageio-2.3:=[${PYTHON_SINGLE_USEDEP}]
		')
		>=dev-util/nvidia-cuda-toolkit-9:=
	)
	optix? (
		>=dev-libs/optix-7.4
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-python/pybind11-2.4.2[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
	partio? (
		>=media-libs/partio-1.13.2
	)
	gui? (
		wayland? (
			dev-qt/qtdeclarative:6[opengl]
			dev-qt/qtwayland:6
		)
		!qt6? (
			dev-qt/qtcore:5
			dev-qt/qtgui:5[wayland?,X?]
			dev-qt/qtwidgets:5[X?]
			dev-qt/qtopengl:5
		)
		qt6? (
			dev-qt/qtbase:6[gui,wayland?,widgets,X?]
		)
	)
	virtual/libc
"

DEPEND="${RDEPEND}
	dev-util/patchelf
	>=media-libs/openexr-3
	sys-libs/zlib
	test? (
		media-fonts/droid
		optix? (
			cuda? (
				dev-util/nvidia-cuda-toolkit
			)
			dev-libs/optix
		)
	)
"
BDEPEND="
	app-alternatives/yacc
	app-alternatives/lex
	virtual/pkgconfig
"

PATCHES+=(
	"${FILESDIR}/${PN}-include-cstdint.patch"
)

get_lib_type() {
	use static-libs && echo "static"
	echo "shared"
}

pkg_setup() {
	llvm-r1_pkg_setup

	use python && python-single-r1_pkg_setup
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
		cuda_add_sandbox -w
	fi
	sed -e 's/DESTINATION cmake/DESTINATION "${OSL_CONFIG_INSTALL_DIR}"/g' \
		-re '/install \(FILES src\/build-scripts\/serialize-bc\.py/{:a;N;/PERMISSIONS \$\{PERMISSION_FLAGS\}\)/!ba};/DESTINATION build-scripts/d' \
		-i CMakeLists.txt || die "Sed failed."
	sed -e "/^install.*llvm_macros.cmake.*cmake/d" -i CMakeLists.txt || die
	sed -e "/install_targets ( libtestshade )/d" -i src/testshade/CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	configure_abi() {
		local lib_type
		for lib_type in $(get_lib_type) ; do
			export CMAKE_USE_DIR="${S}"
			export BUILD_DIR="${S}-${MULTILIB_ABI_FLAG}.${ABI}_${lib_type}_build"
			cd "${CMAKE_USE_DIR}" || die

			local cpufeature
			local mysimd=()
			if use cpu_flags_x86_avx512f; then
				mysimd+=( avx512f )
			elif use cpu_flags_x86_avx2 ; then
				mysimd+=( avx2 )
				if use cpu_flags_x86_f16c ; then
					mysimd+=( f16c )
				fi
			elif use cpu_flags_x86_avx ; then
				mysimd+=( avx )
			elif use cpu_flags_x86_sse4_2 ; then
				mysimd+=( sse4.2 )
			elif use cpu_flags_x86_sse4_1 ; then
				mysimd+=( sse4.1 )
			elif use cpu_flags_x86_ssse3 ; then
				mysimd+=( ssse3 )
			elif use cpu_flags_x86_sse3 ; then
				mysimd+=( sse3 )
			elif use cpu_flags_x86_sse2 ; then
				mysimd+=( sse2 )
			fi

			local mybatched=()
			if use cpu_flags_x86_avx512f || use cpu_flags_x86_avx2 ; then
				if use cpu_flags_x86_avx512f ; then
					if use nofma; then
						mybatched+=(
							"b8_AVX512_noFMA"
							"b16_AVX512_noFMA"
						)
					fi
					mybatched+=(
						"b8_AVX512"
						"b16_AVX512"
					)
				fi
				if use cpu_flags_x86_avx2 ; then
					if use nofma; then
						mybatched+=(
							"b8_AVX2_noFMA"
						)
					fi
					mybatched+=(
						"b8_AVX2"
					)
				fi
			fi
			if use cpu_flags_x86_avx ; then
				mybatched+=(
					"b8_AVX"
				)
			fi

			# If no CPU SIMDs were used, completely disable them
			[[ -z "${mysimd[*]}" ]] && mysimd=("0")
			[[ -z "${mybatched[*]}" ]] && mybatched=("0")


			# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
			# Even if there are no SIMD features selected, it seems like the code will turn on NEON support if it is available.
			use arm64 && append-flags -flax-vector-conversions

			filter-flags -no-opaque-pointers

			local gcc="$(tc-getCC)"
			local mycmakeargs=(
				-DCMAKE_POLICY_DEFAULT_CMP0146="OLD" # BUG FindCUDA
				-DCMAKE_CXX_STANDARD=17
				#-DLLVM_ROOT="${EPREFIX}/usr/lib/llvm/${LLVM_SLOT}"
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
				-DUSE_CUDA=$(usex cuda)
				-DUSE_OPTIX=$(usex optix) # for v1.12
				-DOSL_USE_OPTIX=$(usex optix) # for v1.13
				-DUSE_PARTIO=$(usex partio)
				-DUSE_QT=$(usex gui)
				-DUSE_PYTHON=$(usex python)
				-DUSE_SIMD="$(IFS=","; echo "${mysimd[*]}")"
			)

			if use python; then
				mycmakeargs+=(
				  -DPYTHON_VERSION="${EPYTHON/python}"
				  -DPYTHON_SITE_DIR="$(python_get_sitedir)"
				)
			fi

			if use cuda; then
				for CT in ${CUDA_TARGETS_COMPAT[@]}; do
					use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT};"
				done

				mycmakeargs+=(
					-DCUDA_TARGET_ARCH="${CUDA_TARGETS%%;}"
					-DCUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
				)
			fi
			CMAKE_BUILD_TYPE=$(usex debug 'RelWithDebInfo' 'Release')
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
	# A bunch of tests only work when installed.
	# So install them into the temp directory now.
	DESTDIR="${T}" cmake_build install

	ln -s "${CMAKE_USE_DIR}/src/cmake/" "${BUILD_DIR}/src/cmake" || die

	local -x DEBUG CXXFLAGS LD_LIBRARY_PATH DIR OSL_DIR OSL_SOURCE_DIR PYTHONPATH
	DEBUG=1 # doubles the floating point tolerance so we avoid FMA related issues
	CXXFLAGS="-I${T}/usr/include"
	LD_LIBRARY_PATH="${T}/usr/$(get_libdir)"
	OSL_DIR="${T}/usr/$(get_libdir)/cmake/OSL"
	OSL_SOURCE_DIR="${S}"
	# local -x OSL_TESTSUITE_SKIP_DIFF=1
	local -x OPENIMAGEIO_DEBUG=0

	if use python; then
		PYTHONPATH="${BUILD_DIR}/lib/python/site-packages"
	fi

	if use optix; then
		cp \
			"${BUILD_DIR}/src/liboslexec/shadeops_cuda.ptx" \
			"${BUILD_DIR}/src/testrender/"{optix_raytracer,rend_lib_testrender}".ptx" \
			"${BUILD_DIR}/src/testshade/"{optix_grid_renderer,rend_lib_testshade}".ptx" \
			"${BUILD_DIR}/bin/" || die

		# NOTE this should go to cuda eclass
		cuda_add_sandbox -w
		addwrite "/proc/self/task/"
		addpredict "/dev/char/"
	fi

	local CMAKE_SKIP_TESTS=(
		"-broken$"

		# broken with in-tree <=dev-libs/optix-7.5.0 and out of date
		"^example-cuda"

		# outright fail
		# batchregression
		"^spline-reg.regress.batched.opt$"
		"^transform-reg.regress.batched.opt$"
		"^texture3d-opts-reg.regress.batched.opt$"

		# doesn't handle parameters
		"^osl-imageio"

		# render
		"^render-bunny.opt$"
		"^render-displacement.opt$"
		"^render-microfacet.opt$"
		"^render-veachmis.opt$"

		# optix
		"^render-mx-generalized-schlick.optix$"
		"^render-mx-generalized-schlick.optix.opt$"
		"^render-mx-generalized-schlick.optix.fused$"
		"^render-microfacet.optix.opt$"
		"^render-microfacet.optix.fused$"
	)

	local myctestargs=(
		-LE 'render'
		# src/build-scripts/ci-test.bash
		# '--force-new-ctest-process'
	)

	OPENIMAGEIO_CUDA=0 \
	cmake_src_test

	einfo ""
	einfo "testing render tests in isolation"
	einfo ""

	myctestargs=(
		-L "render"
		# src/build-scripts/ci-test.bash
		'--force-new-ctest-process'
		--repeat until-pass:10
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
	if [[ -d "${ED}/usr/build-scripts" ]]; then
		rm -vr "${ED}/usr/build-scripts" || die
	fi

	if use test; then
		rm \
			"${ED}/usr/bin/test"{render,shade{,_dso}} \
			|| die
	fi

	if use amd64; then
		find "${ED}/usr/$(get_libdir)" -type f  -name 'lib_*_oslexec.so' -print0 \
			| while IFS= read -r -d $'\0' batched_lib; do
			patchelf --set-soname "$(basename "${batched_lib}")" "${batched_lib}" || die
		done
	fi
}
