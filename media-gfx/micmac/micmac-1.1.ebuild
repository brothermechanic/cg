# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils eutils

DOCV="31342a59eac40f7c24e59c4e8aec6ce46269f169"

DESCRIPTION="Photorgammetry (SFM) software"
HOMEPAGE="http://logiciels.ign.fr/?-Micmac,3- https://github.com/micmacIGN/micmac/"
SRC_URI="https://github.com/micmacIGN/micmac/archive/MMASTER_v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="CeCILL-B"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+qt5 opencl -cuda +proj X doc mpi"

RDEPEND="
	media-gfx/imagemagick
	media-gfx/exiv2
	qt5? ( dev-qt/qtcore:5 )
	cuda? (
		>=dev-util/nvidia-cuda-toolkit-10.1.105
		>=dev-util/nvidia-cuda-sdk-10.1.105[-examples]
		>=dev-libs/boost-1.70.0
	)
	proj? ( >=sci-libs/proj-6.0.0 )
	opencl? ( virtual/opencl )
	mpi? ( virtual/mpi )
	sci-libs/geos
	>=sci-libs/gdal-2.4.1"

DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/Apero2Meshlab.patch
	"${FILESDIR}"/cuda.patch
	"${FILESDIR}"/GpGpu_cmake.patch
	"${FILESDIR}"/GpGpu_cmake2.patch
	"${FILESDIR}"/CPP_CilliaCol.cpp.patch
	"${FILESDIR}"/CPP_CilliaMap.cpp.patch
	"${FILESDIR}"/cParamNewRechPH.h.patch
	"${FILESDIR}"/ptxd_h.patch
	"${FILESDIR}"/cSysCoor.cpp.patch
)



S="${WORKDIR}/${PN}-MMASTER_v${PV}"
# S_DOC="${WORKDIR}/Documentation-${DOCV}"

CMAKE_BUILD_TYPE=Release

src_prepare() {
	cmake-utils_src_prepare
#	rm -r {bin,lib}
	cp "${FILESDIR}"/Apero2Meshlab.c src/CBinaires/ || die
	sed -i -e "s/-Werror/-Wall -Werror -Wno-strict-aliasing -Wno-format-overflow -Wno-maybe-uninitialized -Wno-parentheses -Wno-class-memaccess -Wno-deprecated-declarations/g" CMakeLists.txt || die
	sed -i -e "s/-Werror/-Werror -Wall -Wno-strict-aliasing -Wno-format-overflow -Wno-maybe-uninitialized -Wno-parentheses -Wno-class-memaccess -Wno-deprecated-declarations/g" BenchElise/bench/Makefile || die
}

# 		SET(Boost_USE_STATIC_LIBS ON)

src_configure() {
	if use cuda; then
		addwrite /dev/nvidiactl
		addwrite /dev/nvidia0
		addwrite /dev/nvidia-uvm
#		perm nvidia-modprobe
#		nvcc -std=c++11 --expt-relaxed-constexpr -O3 -DADD_ -Xcompiler -fPIC -D__CORRECT_ISO_CPP11_MATH_H_PROTO -Wno-deprecated-gpu-targets
#		-DCUDA_NVCC_FLAGS=-std=c++11 --expt-relaxed-constexpr -O3 -DADD_ -Xcompiler -fPIC -D__CORRECT_ISO_CPP11_MATH_H_PROTO -Wno-deprecated-gpu-targets
	fi
#	local mycmakeargs
#	=(
#		-DCXX_FLAGS="-std=c++11"
#	)
#		-DCMAKE_C_COMPILER=/usr/bin/gcc-5
#		-DCMAKE_CXX_COMPILER=/usr/bin/g++-5
#		-DBOOST_INCLUDEDIR="/usr/include/"
	local mycmakeargs=(
		-DWITH_INTERFACE=OFF # build graphic interface
		-DWITH_KAKADU=OFF # KAKADU Support
		-DWITH_IGN_ORI=OFF # Include Ign orientation
		-DWITH_IGN_IMAGE=OFF # Include Ign image
		-DWITH_HEADER_PRECOMP=ON # En-tetes precompilees
		-DBUILD_ONLY_ELISE_MM3D=OFF # Projet Elise et MM3D uniquement
		-DWITH_ETALONPOLY=ON # Build etalonnage polygone
		-DBUILD_POISSON=ON # Build Poisson binaries
		-DBUILD_RNX2RTKP=ON # Build Rnx2rtkp binaries
		-DCUDA_ENABLED=$(usex cuda ON OFF) # Utilisation de cuda
		-DWITH_OPENCL=$(usex opencl ON OFF) # Utilisation d'OpenCL
		-DWITH_OPEN_MP=$(usex mpi ON OFF) # use OpenMP
		-DTRACE_SYSTEM=OFF # print system calls
		-DBUILD_BENCH=OFF # compile low-level test bench
		-DWITH_QT5=$(usex qt5 ON OFF) # compile Qt interfaces
		-DWITH_CPP11=ON # Compilateur C++11
		-DWITH_GIMMI=OFF # Graphical Interface GIMMI
		-DDEPLOY=OFF # compile for end-user
		-DWITH_DOXYGEN=$(usex doc ON OFF) # Generation de documentation
		#
		-DMICMAC_USE_PROJ4=$(usex proj ON OFF)
		-DCUDA_LINEINFO=$(usex cuda OFF ON)
		-DCUDA_FASTMATH=$(usex cuda ON OFF)
		-DCUDA_NVTOOLS=$(usex cuda ON OFF)
		-DCUDA_CPP11THREAD_NOBOOSTTHREAD=$(usex cuda ON OFF)
		-DCUDA_NVCC_EXECUTABLE="/opt/cuda/bin/nvcc"
		-DCUDA_SDK_ROOT_DIR="/opt/cuda/sdk/"
		-DCUDA_SAMPLE_DIR="/opt/cuda/sdk/"
		-DCMAKE_INSTALL_PREFIX="/usr"
		-DNO_X11=$(usex X OFF ON)
	)
	cmake-utils_src_configure
}

src_install() {
	cd  ${BUILD_DIR}
	make install
	insinto /usr
	doins -r ${S}/{lib,data,include}
#	if use doc; then
#		doins -r ${S}/Documentation
#	fi
	exeinto /usr/bin
	doexe ${S}/bin/*
	doexe ${S}/binaire-aux/linux/*
}
