# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
PYTHON_COMPAT=( python3_{10..12} )
inherit python-single-r1 cmake cuda

DESCRIPTION="Cross-platform inference and training machine-learning accelerator."
HOMEPAGE="https://onnxruntime.ai"
SRC_URI="https://github.com/microsoft/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="mirror test"
CUDA_ARCHS="sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 sm_87 sm_89 sm_90"
IUSE="cuda dnn debug +python +mpi test tensorrt ${CUDA_ARCHS}"

RDEPEND="
	dev-libs/protobuf:=
"

BDEPEND="
	${PYTHON_DEPS}
	app-admin/chrpath
	dev-cpp/abseil-cpp
	dev-libs/date
	dev-libs/nsync:=
	dev-libs/flatbuffers:=
	sys-cluster/openmpi:=[cuda?]
	dev-cpp/eigen:=[cuda?]
	dev-cpp/nlohmann_json
	sci-libs/pytorch
	dev-libs/re2
	cuda? (
		dev-util/nvidia-cuda-toolkit:12=
		dev-libs/cudnn:=
	)
	dnn? (
		dev-libs/oneDNN:=
	)
	tensorrt? (
		sci-libs/tensorboard:=
	)
	python? (
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/h5py[${PYTHON_USEDEP}]
			dev-python/cerberus[${PYTHON_USEDEP}]
			dev-python/coloredlogs[${PYTHON_USEDEP}]
			dev-python/flatbuffers[${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/sympy[${PYTHON_USEDEP}]
			dev-python/protobuf[${PYTHON_USEDEP}]
			dev-python/psutil[${PYTHON_USEDEP}]
			dev-python/py-cpuinfo[${PYTHON_USEDEP}]
		')
	)
"

PATCHES=(
	#"${FILESDIR}/onnxruntime-build-fixes.patch"
	"${FILESDIR}/${PN}-system-dnnl.patch"
	"${FILESDIR}/${PN}-system-flatbuffers.patch"
)

src_prepare() {
	CMAKE_USE_DIR="${S}/cmake"

	use cuda && cuda_src_prepare

	# Workaround for binary drivers.
	addpredict /dev/ati
	addpredict /dev/dri
	addpredict /dev/nvidiactl

	# find system nlohmann-json
  	sed 's|3.10 ||g' -i cmake/external/onnxruntime_external_deps.cmake

	# find system chrono-date
	sed -e 's|${DEP_SHA1_date}|&\n \ \ \ \ \ \FIND_PACKAGE_ARGS NAMES date|g' \
		-e 's|date_interface|date::date-tz|g' \
    	-i cmake/external/onnxruntime_external_deps.cmake \
    	-i cmake/onnxruntime_common.cmake \
    	-i cmake/onnxruntime_unittests.cmake

	# find system abseil-cpp
	sed 's|ABSL_PATCH_COMMAND}|&\n\ \ \ \ \FIND_PACKAGE_ARGS NAMES absl|g' \
    	-i cmake/external/abseil-cpp.cmake

	# find system cxxopts
  	sed 's|${DEP_SHA1_cxxopts}|&\n\ \ \ \ \FIND_PACKAGE_ARGS NAMES cxxopts|g' \
    	-i cmake/external/onnxruntime_external_deps.cmake

	# update boost mp11
	sed -e 's|boost-1.79.0|boost-1.81.0|g' \
    	-e 's|c8f04e378535ededbe5af52c8f969d2dedbe73d5|fdad7d98d7239423e357bb49e725382a814f695c|g' \
    	-i cmake/deps.txt

    # fix build with gcc12(?), take idea from https://github.com/microsoft/onnxruntime/pull/11667 and https://github.com/microsoft/onnxruntime/pull/10014
	sed 's|dims)|TensorShape(dims))|g' \
		-i onnxruntime/contrib_ops/cuda/quantization/qordered_ops/qordered_qdq.cc

	# fix missing #include <iostream>
	sed '11a#include <iostream>' -i orttraining/orttraining/test/training_api/trainer/trainer.cc

	if use tensorrt; then
		# Tensorrt 8.6 EA
    	eapply "${FILESDIR}/15089.diff"

		# Update Tensorboard 00d59e65d866a6d4b9fe855dce81ee6ba8b40c4f
    	sed -e 's|373eb09e4c5d2b3cc2493f0949dc4be6b6a45e81|00d59e65d866a6d4b9fe855dce81ee6ba8b40c4f|g' \
        	-e 's|67b833913605a4f3f499894ab11528a702c2b381|ff427b6a135344d86b65fa2928fbd29886eefaec|g' \
        	-i cmake/deps.txt
	    # Update onnx_tensorrt 6872a9473391a73b96741711d52b98c2c3e25146
    	sed -e 's|369d6676423c2a6dbf4a5665c4b5010240d99d3c|6872a9473391a73b96741711d52b98c2c3e25146|g' \
        	-e 's|62119892edfb78689061790140c439b111491275|75462057c95f7fdbc256179f0a0e9e4b7be28ae3|g' \
        	-i cmake/deps.txt
	fi

	cmake_src_prepare
}

src_configure() {
	python && python_setup
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	append-cxxflags -Wno-dangling-reference -Wno-c++20-compat

	local mycmakeargs=(
		-DONNX_USE_PROTOBUF_SHARED_LIBS=ON
		-Donnxruntime_BUILD_SHARED_LIB=ON
		-Donnxruntime_ENABLE_PYTHON=$(usex python)
    	-Donnxruntime_PREFER_SYSTEM_LIB=ON
	    -Donnxruntime_BUILD_UNIT_TESTS=$(usex test)
	    -Donnxruntime_ENABLE_TRAINING=ON
	    -Donnxruntime_ENABLE_LAZY_TENSOR=OFF
    	-Donnxruntime_USE_MPI=$(usex mpi)
    	-Donnxruntime_USE_PREINSTALLED_EIGEN=ON
    	-Donnxruntime_USE_DNNL=$(usex dnn)
		-Donnxruntime_USE_CUDA=$(usex cuda)
	    -Donnxruntime_CUDA_HOME=/opt/cuda
      	-Donnxruntime_CUDNN_HOME=/usr
      	-Donnxruntime_USE_NCCL=OFF
      	-Donnxruntime_NVCC_THREADS=1
    	-Deigen_SOURCE_PATH=/usr/include/eigen3
	)

	if use cuda; then
		for CA in ${CUDA_ARCHS}; do
			use ${CA} && CUDA_ARCH+="${CA##sm_}-real;"
		done
		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES="${CUDA_ARCH}"
			-DCMAKE_CUDA_HOST_COMPILER="$(cuda_gccdir)"
    		-DCMAKE_CUDA_STANDARD_REQUIRED=ON
    		-DCMAKE_CXX_STANDARD_REQUIRED=ON
    	)
	fi

	cmake_src_configure
	use python && python-single-r1_src_configure
}

src_compile() {
	cmake_src_compile
	use python && python-single-r1_src_compile
}

src_install() {
	cmake_src_install
	use python && python-single-r1_src_install
}
