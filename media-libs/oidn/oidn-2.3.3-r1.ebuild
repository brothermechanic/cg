# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( {17..20} )
PYTHON_COMPAT=( python3_{11..13} )
ROCM_VERSION="6.3"
CUDA_DEVICE_TARGETS=1

inherit cmake cuda flag-o-matic llvm-r1 python-any-r1 rocm toolchain-funcs

DESCRIPTION="Intel Open Image Denoise library"
HOMEPAGE="https://www.openimagedenoise.org https://github.com/RenderKit/oidn"

# MKL_DNN is oneDNN 2.2.4 with additional custom commits.
MKL_DNN_COMMIT="f53274c9fef211396655fc4340cb838452334089"
OIDN_WEIGHTS_COMMIT="28883d1769d5930e13cf7f1676dd852bd81ed9e7"

IUSE="apps +built-in-weights cuda doc hip sycl openimageio test"

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://github.com/RenderKit/oidn.git"
	EGIT_BRANCH="master"
	EGIT_LFS="1"
	inherit git-r3
else
	SRC_URI="
		https://github.com/RenderKit/${PN}/releases/download/v${PV}/${P}.src.tar.gz -> ${P}.tar.gz
		https://github.com/RenderKit/mkl-dnn/archive/${MKL_DNN_COMMIT}.tar.gz -> ${PN}-mkl-dnn-${MKL_DNN_COMMIT:0:7}.tar.gz
		built-in-weights? ( https://github.com/RenderKit/oidn-weights/archive/${OIDN_WEIGHTS_COMMIT}.tar.gz -> ${PN}-weights-${OIDN_WEIGHTS_COMMIT:0:7}.tar.gz )
	"
	KEYWORDS="~amd64 -arm ~arm64 -ppc ~ppc64 -x86" # 64-bit-only
fi

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"

REQUIRED_USE="
	test? ( apps )
	openimageio? ( apps )
"
RESTRICT="
	mirror
	!test? ( test )
"

# See https://github.com/OpenImageDenoise/oidn/blob/v1.4.3/scripts/build.py
RDEPEND="
	${PYTHON_DEPS}
	virtual/libc
	>=dev-cpp/tbb-2021.5:0=
	dev-lang/ispc
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-12.8:=
		dev-libs/cutlass
	)
	hip? (
		dev-util/hip:=
	)
	sycl? (
		dev-libs/intel-compute-runtime[l0]
	)
	openimageio? ( media-libs/openimageio:=[cuda?] )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
    $(llvm_gen_dep '
      llvm-core/clang:${LLVM_SLOT}=
      llvm-core/llvm:${LLVM_SLOT}=
    ')
	>=dev-lang/ispc-1.21.0
	>=dev-build/cmake-3.15
	openimageio? (
		>=media-libs/openimageio-2.4.15.0
	)
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-12.8
	)
	hip? (
		dev-util/hip:=
		sci-libs/composable-kernel
	)
"
DOCS=( "CHANGELOG.md" "README.md" "readme.pdf" )
PATCHES=(
	"${FILESDIR}/${PN}-2.3.3-cuda-nvcc-flags.patch"
	"${FILESDIR}/${PN}-2.3.3-amdgpu-targets.patch"
)

check_cpu() {
	if [[ ! -e "${BROOT}/proc/cpuinfo" ]] ; then
		ewarn
		ewarn "Cannot find ${BROOT}/proc/cpuinfo.  Skipping CPU flag check."
		ewarn
	elif ! grep -F -e "sse4_1" "${BROOT}/proc/cpuinfo" ; then
		ewarn
		ewarn "You need SSE4.1 to use this product."
		ewarn
	fi
}

pkg_setup() {
	if ! tc-is-cross-compiler && use kernel_linux ; then
		check_cpu
	fi

	python-any-r1_pkg_setup
	#rocm_pkg_setup
	llvm-r1_pkg_setup
	if use cuda ; then
		cuda_add_sandbox
	fi
}

src_unpack() {
	unpack ${A}
	# rm -rf "${S}/external/composable_kernel" || die
	rm -rf "${S}/external/cutlass" || die
	rm -rf "${S}/external/mkl-dnn" || die
	ln -s \
		"${WORKDIR}/mkl-dnn-${MKL_DNN_COMMIT}" \
		"${S}/external/mkl-dnn" \
		|| die
	if use built-in-weights ; then
		ln -s "${WORKDIR}/oidn-weights-${OIDN_WEIGHTS_COMMIT}" \
			"${S}/weights" || die
	else
		rm -rf "${WORKDIR}/oidn-weights-${OIDN_WEIGHTS_COMMIT}" || die
	fi
}

src_prepare() {
#   pushd "${S}/external/composable_kernel" || die
#		eapply "${FILESDIR}/composable_kernel-1.0.0_p9999-fix-missing-libstdcxx-expf.patch"
#	popd
	if use cuda; then
		cuda_src_prepare
	fi

	if use hip; then
		# https://bugs.gentoo.org/930391
		sed "/-Wno-unused-result/s:): --rocm-path=${EPREFIX}/usr):" \
			-i devices/hip/CMakeLists.txt || die
	fi

	# do not fortify source -- bug 895018
	sed -e "s/-D_FORTIFY_SOURCE=2//g" -i {cmake/oidn_platform,external/mkl-dnn/cmake/SDL}.cmake || die

	sed -e "/^install.*llvm_macros.cmake.*cmake/d" -i CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	strip-unsupported-flags
	test-flags-CXX "-std=c++17" 2>/dev/null 1>/dev/null \
                || die "Switch to a c++17 compatible compiler."

	# Prevent possible
	# error: Illegal instruction detected: Operand has incorrect register class.
	replace-flags '-O0' '-O1'

	export CC=$(tc-getCC)
	export CXX=$(tc-getCXX)

	einfo
	einfo "CC:\t${CC}"
	einfo "CXX:\t${CXX}"
	einfo "CHOST:\t${CHOST}"
	einfo

	mycmakeargs+=(
		-DCMAKE_CXX_STANDARD=17
		-DCMAKE_CXX_COMPILER="${CXX}"
		-DCMAKE_C_COMPILER="${CC}"
		-DOIDN_APPS="$(usex apps)"
		-DOIDN_INSTALL_DEPENDENCIES="OFF"
		-DOIDN_FILTER_RT="$(usex built-in-weights)"
		-DOIDN_FILTER_RTLIGHTMAP="$(usex built-in-weights)"
		-DOIDN_LIBRARY_VERSIONED="yes"
		-DOIDN_DEVICE_CPU="yes"
		-DOIDN_DEVICE_CUDA="$(usex cuda)"
		-DOIDN_DEVICE_HIP="$(usex hip)"
		-DOIDN_DEVICE_SYCL="$(usex sycl)"
	)

	if use apps; then
		mycmakeargs+=( -DOIDN_APPS_OPENIMAGEIO="$(usex openimageio)" )
	fi


	if use hip; then
		mycmakeargs+=(
			-DROCM_PATH="${EPREFIX}/usr"
			-DOIDN_DEVICE_HIP_COMPILER="${ESYSROOT}/usr/bin/hipcc"
			-DAMDGPU_TARGETS="$(get_amdgpu_flags)"
		)
	fi

	if use cuda ; then
		export CUDAHOSTCXX="$(cuda_gccdir)"
		if use cuda_targets_sm_80 || use cuda_targets_sm_90 ; then
			:;
		else
			sed -i -e "/cutlass_conv_sm80.cu/d" devices/cuda/CMakeLists.txt || die
		fi
		if use cuda_targets_sm_70 ; then
			sed -i -e "/cutlass_conv_sm70.cu/d" devices/cuda/CMakeLists.txt || die
		fi
		if use cuda_targets_sm_75 ; then
			sed -i -e "/cutlass_conv_sm75.cu/d" devices/cuda/CMakeLists.txt || die
		fi

		sed -e "s/oidn_set_cuda_sm_flags(OIDN_CUDA_SM_FLAGS 70 75 80 90 100 120)/oidn_set_cuda_sm_flags(OIDN_CUDA_SM_FLAGS ${CUDA_TARGETS})/g" -i devices/cuda/CMakeLists.txt || die "Sed failed"
		mycmakeargs+=(
			-DCUDAToolkit_ROOT="/opt/cuda"
			-DOIDN_DEVICE_CUDA_COMPILER="/opt/cuda/bin/nvcc"
			-DCUDA_COMPILER_PATH="$(cuda_gccdir)"
			-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)\/g++"
		)
	fi

	CMAKE_BUILD_TYPE=Release
	cmake_src_configure
}

src_compile() {
	if use cuda; then
		addpredict /dev/char/
		cuda_add_sandbox
	fi

	cmake_src_compile
}

src_test() {
	if use cuda; then
		addpredict /dev/char/
		cuda_add_sandbox
	fi

	"${BUILD_DIR}"/oidnTest || die "There were test failures!"
}

src_install() {
	cmake_src_install
	use doc || ( rm -v "${ED}/usr/share/doc/${PF}"/* || die )
	use doc && einstalldocs
	docinto licenses
	dodoc \
		LICENSE.txt \
		third-party-programs.txt \
		third-party-programs-DPCPP.txt \
		third-party-programs-oneDNN.txt \
		third-party-programs-oneTBB.txt

	if use hip || use cuda || use sycl; then
		# remove garbage in /var/tmp left by subprojects
		rm -r "${ED}/var" || die
	fi
}
