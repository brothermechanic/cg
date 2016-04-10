# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit cmake-utils eutils git-2

DESCRIPTION="Open Shading Language"
HOMEPAGE="https://github.com/imageworks/OpenShadingLanguage"
EGIT_REPO_URI="https://github.com/imageworks/OpenShadingLanguage.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="test tbb"

DEPEND="
	>=dev-libs/boost-1.57.0
	>=media-libs/openimageio-1.5.15
	sys-devel/bison
	sys-devel/flex
	>=media-libs/ilmbase-2.0
	tbb? ( dev-cpp/tbb )
	<sys-devel/llvm-3.6[clang]"

RDEPEND=""

S="${WORKDIR}/OpenShadingLanguage-Release"

src_configure() {
	append-cxxflags -std=gnu++11 -Wno-error=array-bounds -Wno-error=sign-compare
	local mycmakeargs=""
	mycmakeargs=(
		${mycmakeargs}
		$(cmake-utils_use_use tbb TBB)
		$(cmake-utils_use_build test TESTING)
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLLVM_LIB_DIR=/usr/lib
		-DLLVM_LIBRARY=/usr/lib/libLLVMCore.so
		-DPUGIXML_HOME=/usr/lib
		-DILMBASE_VERSION=2
		-DOSL_BUILD_CPP11=ON
		-DOSL_BUILD_LIBCPLUSPLUS=ON
		-DUSE_EXTERNAL_PUGIXML=ON
		-DUSE_SIMD="sse4.2"
		-DVERBOSE=ON
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
	mkdir -p "${D}"/usr/share/OSL/
	mv "${D}"/usr/{CHANGES,INSTALL,LICENSE,README.md,shaders,doc} "${D}"/usr/share/OSL/ || die
}
