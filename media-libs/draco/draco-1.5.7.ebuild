# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Notes:
# - We don't add USE flags for ccache and distcc, because the library builds
#   in minimal time (a few seconds)

EAPI=8

inherit cmake

DESCRIPTION="Library for compressing and decompressing 3D geometric objects"
HOMEPAGE="https://google.github.io/draco/"
SRC_URI="https://github.com/google/draco/archive/${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"

SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm64"

IUSE="+compat gltf usd javascript transcoder test"

RDEPEND="
	dev-cpp/eigen:=
	javascript? ( dev-util/emscripten[llvm_targets_WebAssembly(+)] )
	usd? ( media-libs/openusd )
"

DEPEND="${RDEPEND}
	virtual/pkgconfig"
# Testing needs the dev-cpp/gtest source code to be available in a
# side-directory of the draco sources, therefore we restrict test for now.
RESTRICT="test mirror"
DOCS=( AUTHORS CONTRIBUTING.md README.md )

PATCHES=(
	"${FILESDIR}/draco-fix-include-cstdint.patch"
)

src_configure() {
	CMAKE_BUILD_TYPE=Release
	EMSCRIPTEN=
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=17
		-DDRACO_EIGEN_PATH="${EPREFIX}/usr/include/eigen3"
		#-DDRACO_TINYGLTF_PATH=
		# currently only used for javascript/emscripten build
		-DDRACO_ANIMATION_ENCODING=$(usex javascript)
		-DDRACO_WASM=$(usex javascript)
		-DDRACO_GLTF_BITSTREAM=$(usex gltf)
#		-DDRACO_MAYA_PLUGIN=OFF # default
		-DBUILD_SHARED_LIBS=ON
#		-DDRACO_UNITY_PLUGIN=OFF # default (FIXME?)
		#-DBUILD_USD_PLUGIN=$(usex usd) # default
		-DDRACO_BACKWARDS_COMPATIBILITY=$(usex compat)
		# currently only used for javascript/emscripten build and by default
		# set to on with C/C++ build
		-DDRACO_TRANSCODER_SUPPORTED=$(usex transcoder)
		-DENABLE_DECODER_ATTRIBUTE_DEDUPLICATION=OFF
		-DENABLE_EXTRA_SPEED=OFF # don't use -O3 optimization
		#-DENABLE_EXTRA_WARNINGS=OFF
		-DDRACO_MESH_COMPRESSION=ON # default
		-DDRACO_POINT_CLOUD_COMPRESSION=ON # default
		-DDRACO_PREDICTIVE_EDGEBREAKER=ON # default
		-DDRACO_STANDARD_EDGEBREAKER=ON # default
		-DDRACO_TESTS=$(usex test)
		#-DENABLE_WERROR=OFF # default
		#-DENABLE_WEXTRA=OFF # add extra compiler warnings
	)

	cmake_src_configure
}
