# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

AMDGPU_TARGETS_COMPAT=(
	gfx900
	gfx902
	gfx909
	gfx90c
	gfx1030
	gfx1031
	gfx1032
	gfx1033
	gfx1034
	gfx1035
	gfx1036
	gfx1100
	gfx1101
	gfx1102
	gfx1103
)

CUDA_TARGETS_COMPAT=(
	sm_30
	sm_50
	sm_60
	sm_61
	sm_70
	sm_75
	sm_80
	sm_86
	sm_90
)

ROCM_VERSION="5.7.1"
PYTHON_COMPAT=( python3_{10..13} )
LLVM_COMPAT=( {17..19} )

inherit cmake cuda flag-o-matic llvm-r1 python-single-r1 rocm toolchain-funcs

DESCRIPTION="Intel(R) Open Image Denoise library"
HOMEPAGE="http://www.openimagedenoise.org/"
LICENSE="Apache-2.0"
# MKL_DNN is oneDNN 2.2.4 with additional custom commits.
COMPOSABLE_KERNEL_COMMIT="e85178b4ca892a78344271ae64103c9d4d1bfc40"
CUTLASS_COMMIT="66d9cddc832c1cdc2b30a8755274f7f74640cfe6"
MKL_DNN_COMMIT="9bea36e6b8e341953f922ce5c6f5dbaca9179a86"
OIDN_WEIGHTS_COMMIT="44ff866123ffd6c26bbc27e5e48e8cd4ec8a1a66"
ORG_GH="https://github.com/RenderKit"
SLOT="0/$(ver_cut 1-2)"
IUSE="
-${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
-${AMDGPU_TARGETS_COMPAT[@]/#/amdgpu_targets_}
examples +built-in-weights -cuda doc -hip static-libs sycl openimageio test
"

gen_required_use_cuda_targets() {
	local x
	for x in ${CUDA_TARGETS_COMPAT[@]} ; do
		echo "
			cuda_targets_${x}? (
				cuda
			)
		"
	done
}

gen_required_use_hip_targets() {
	local x
	for x in ${AMDGPU_TARGETS_COMPAT[@]} ; do
		echo "
			amdgpu_targets_${x}? (
				hip
			)
		"
	done
}

REQUIRED_USE+="
	$(gen_required_use_cuda_targets)
	$(gen_required_use_hip_targets)
	${PYTHON_REQUIRED_USE}
	openimageio? ( examples )
	cuda? (
		|| (
			${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
		)
	)
	hip? (
		${ROCM_REQUIRED_USE}
	)
"

HIP_VERSIONS=(
	"5.7.1"
	"5.6.1"
) # 5.3.0 fails

gen_hip_depends() {
	local hip_version
	for hip_version in ${HIP_VERSIONS[@]} ; do
		# Needed because of build failures
		local s=$(ver_cut 1-2 ${hip_version})
		echo "
			(
				~dev-libs/rocm-comgr-${hip_version}
				~dev-libs/rocm-device-libs-${hip_version}
				~dev-libs/rocr-runtime-${hip_version}
				~dev-libs/roct-thunk-interface-${hip_version}
				~dev-util/hip-${hip_version}
				~dev-util/rocminfo-${hip_version}
			)
		"
	done
}

# See https://github.com/OpenImageDenoise/oidn/blob/v1.4.3/scripts/build.py
RDEPEND+="
	${PYTHON_DEPS}
	virtual/libc
	dev-lang/ispc
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-11.8:=
	)
	hip? (
		|| (
			$(gen_hip_depends)
		)
		dev-util/hip:=
	)
	sycl? (
		dev-libs/intel-compute-runtime[l0]
	)
	>=dev-cpp/tbb-2021.5:0=
	openimageio? ( media-libs/openimageio:= )
"
DEPEND="${RDEPEND}"
BDEPEND+="
	${PYTHON_DEPS}
    $(llvm_gen_dep '
      llvm-core/clang:${LLVM_SLOT}=
      llvm-core/llvm:${LLVM_SLOT}=
    ')
	>=dev-lang/ispc-1.17.0
	>=dev-build/cmake-3.15
	examples? (
		>=media-libs/openimageio-2.4.15.0[${PYTHON_SINGLE_USEDEP}]
	)
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-11.8
	)
	hip? (
		|| (
			$(gen_hip_depends)
		)
	)
"
if [[ ${PV} = *9999 ]]; then
	EGIT_REPO_URI="${ORG_GH}/oidn.git"
	EGIT_BRANCH="master"
	KEYWORDS=""
	inherit git-r3
else
	SRC_URI="
${ORG_GH}/${PN}/releases/download/v${PV}/${P}.src.tar.gz
	-> ${P}.tar.gz
${ORG_GH}/mkl-dnn/archive/${MKL_DNN_COMMIT}.tar.gz
	-> ${PN}-mkl-dnn-${MKL_DNN_COMMIT:0:7}.tar.gz
	built-in-weights? (
${ORG_GH}/oidn-weights/archive/${OIDN_WEIGHTS_COMMIT}.tar.gz
	-> ${PN}-weights-${OIDN_WEIGHTS_COMMIT:0:7}.tar.gz
	)
https://github.com/ROCmSoftwarePlatform/composable_kernel/archive/${COMPOSABLE_KERNEL_COMMIT}.tar.gz
	-> composable_kernel-${COMPOSABLE_KERNEL_COMMIT:0:7}.tar.gz
https://github.com/NVIDIA/cutlass/archive/${CUTLASS_COMMIT}.tar.gz
	-> cutlass-${CUTLASS_COMMIT:0:7}.tar.gz
	"
	KEYWORDS="~amd64 ~x86"
fi
RESTRICT="mirror !test? ( test )"
DOCS=( CHANGELOG.md README.md readme.pdf )
PATCHES=(
	"${FILESDIR}/${PN}-2.2.2-amdgpu-targets.patch"
	"${FILESDIR}/${PN}-2.2.1-hip-buildfiles-changes.patch"
	"${FILESDIR}/${PN}-2.0.1-set-rocm-path.patch"
	"${FILESDIR}/${PN}-2.1.0-cuda-nvcc-flags.patch"
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

	python-single-r1_pkg_setup
	if has_version "dev-util/hip:5.7" ; then
		ROCM_SLOT="5.7"
	elif has_version "dev-util/hip:5.6" ; then
		ROCM_SLOT="5.6"
	fi
	#rocm_pkg_setup
	llvm-r1_pkg_setup
	if use cuda ; then
		cuda_add_sandbox
	fi
}

src_unpack() {
	unpack ${A}
	rm -rf "${S}/external/composable_kernel" || die
	rm -rf "${S}/external/cutlass" || die
	rm -rf "${S}/external/mkl-dnn" || die
	ln -s \
		"${WORKDIR}/mkl-dnn-${MKL_DNN_COMMIT}" \
		"${S}/external/mkl-dnn" \
		|| die
	ln -s \
		"${WORKDIR}/cutlass-${CUTLASS_COMMIT}" \
		"${S}/external/cutlass" \
		|| die
	ln -s \
		"${WORKDIR}/composable_kernel-${COMPOSABLE_KERNEL_COMMIT}" \
		"${S}/external/composable_kernel" \
		|| die
	if use built-in-weights ; then
		ln -s "${WORKDIR}/oidn-weights-${OIDN_WEIGHTS_COMMIT}" \
			"${S}/weights" || die
	else
		rm -rf "${WORKDIR}/oidn-weights-${OIDN_WEIGHTS_COMMIT}" || die
	fi
}

src_prepare() {
	pushd "${S}/external/composable_kernel" || die
		eapply "${FILESDIR}/composable_kernel-1.0.0_p9999-fix-missing-libstdcxx-expf.patch"
	popd
	if use cuda; then
		cuda_src_prepare
		addpredict "/proc/self/task/"
	fi

	if use hip; then
		# https://bugs.gentoo.org/930391
		sed "/-Wno-unused-result/s:): --rocm-path=${EPREFIX}/usr/lib):" \
			-i devices/hip/CMakeLists.txt || die
	fi

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
		-DOIDN_APPS="$(usex examples)"
		-DOIDN_INSTALL_DEPENDENCIES="OFF"
		-DOIDN_FILTER_RT="$(usex built-in-weights)"
		-DOIDN_FILTER_RTLIGHTMAP="$(usex built-in-weights)"
		-DOIDN_DEVICE_CPU="ON"
		-DOIDN_DEVICE_CUDA="$(usex cuda)"
		-DOIDN_DEVICE_HIP="$(usex hip)"
		-DOIDN_DEVICE_SYCL="$(usex sycl)"
	)

	if use examples ; then
		mycmakeargs+=(
			-DOIDN_APPS_OPENIMAGEIO="$(usex openimageio)"
		)
	fi

	if use hip ; then
		local llvm_slot=$(grep -e "HIP_CLANG_ROOT.*/lib/llvm" \
				"/usr/$(get_libdir)/cmake/hip/hip-config.cmake" \
			| grep -E -o -e  "[0-9]+")
		[[ -n "${llvm_slot}" ]] && "HIP_CLANG_ROOT is missing.  emerge hip."
		einfo "${ESYSROOT}/usr/lib/llvm/${LLVM_SLOT}"
		mycmakeargs+=(
			-DHIP_COMPILER_PATH="${ESYSROOT}/usr/lib/llvm/${LLVM_SLOT}"
			-DOIDN_DEVICE_HIP_COMPILER="${CXX}"
		)

		mycmakeargs+=(
			-DGPU_TARGETS="$(get_amdgpu_flags)"
		)
		einfo "AMDGPU_TARGETS:\t${targets}"
	fi

	if use cuda ; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="-gencode arch=compute_${CT#sm_*},code=${CT} "
		done
		( use cuda_targets_sm_80 || use cuda_targets_sm_90 ) && \
			sed -e 's/cuda_engine.cu/&\n  cutlass_conv_sm80.cu/' -i devices/cuda/CMakeLists.txt
		use cuda_targets_sm_75 && sed -e 's/cuda_engine.cu/&\n  cutlass_conv_sm75.cu/' -i devices/cuda/CMakeLists.txt
		use cuda_targets_sm_70 && sed -e 's/cuda_engine.cu/&\n  cutlass_conv_sm70.cu/' -i devices/cuda/CMakeLists.txt

		sed -e "33i\set(OIDN_NVCC_FLAGS \"-forward-unknown-opts -fno-lto ${NVCCFLAGS//\"/} ${CUDA_TARGETS%% }\")" -i devices/cuda/CMakeLists.txt || die "Sed failed"
		mycmakeargs+=(
			-DCUDAToolkit_ROOT="/opt/cuda"
			-DOIDN_DEVICE_CUDA_COMPILER="/opt/cuda/bin/nvcc"
			-DCUDA_COMPILER_PATH="$(cuda_gccdir)"
			-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)\/g++"
		)

		einfo "CUDA_TARGETS:\t${CUDA_TARGETS//*=/}"
		einfo "NVCCFLAGS:\t${NVCCFLAGS}"
	fi

	cmake_src_configure
}

src_test() {
	"${BUILD_DIR}"/oidnTest || die "There were test faliures!"
}

src_install() {
	cmake_src_install
	if ! use doc ; then
		rm -vrf "${ED}/usr/share/doc/oidn-${PV}/readme.pdf" || die
	fi
	use doc && einstalldocs
	docinto licenses
	dodoc LICENSE.txt

	# remove garbage in /var/tmp left by subprojects
	rm -rf "${ED}/var"
}

pkg_postinst() {
	if use hip ; then
		ewarn
		ewarn "All APU + GPU HIP targets on the device must be built/installed to avoid"
		ewarn "a crash."
		ewarn
	fi
}
