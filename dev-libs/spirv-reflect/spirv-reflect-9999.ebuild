# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
EAPI=8
inherit cmake

DESCRIPTION="Lightweight library that provides a C/C++ reflection API for SPIR-V shader bytecode in Vulkan applications"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Reflect"

if [[ ${PV} = *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Reflect"
	EGIT_BRANCH="master"
	KEYWORDS=""
else
	SRC_URI="https://github.com/KhronosGroup/SPIRV-Reflect/archive/refs/tags/vulkan-sdk-${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
	S="${WORKDIR}/SPIRV-Reflect-vulkan-sdk-${PV}"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="debug examples static-libs test"

BDEPEND="
	>=dev-util/vulkan-headers-1.3.135.0
	>=dev-util/spirv-headers-1.3.135.0
"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/spirv-reflect-9999-build-shared-libs-276.patch"
	"${FILESDIR}/spirv-reflect-9999-use-system-headers.patch"
)

src_prepare() {
	cmake_src_prepare
	sed -e "/ DESTINATION /s:lib:$(get_libdir):" -i CMakeLists.txt || die
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug "RelWithDebInfo" "Release")
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DSPIRV_REFLECT_EXECUTABLE="OFF"
		-DSPIRV_REFLECT_STATIC_LIB=$(usex static-libs)
		-DSPIRV_REFLECT_BUILD_TESTS=$(usex test)
		-DSPIRV_REFLECT_ENABLE_ASSERTS=$(usex debug)
	)
	cmake_src_configure
}

src_install(){
	# Install headers
	insinto /usr/include/SPIRV-Reflect
	doins spirv_reflect.h spirv_reflect.c

	cmake_src_install
}

