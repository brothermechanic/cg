# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT_HASH="e722e57c891a8fbe3cc73ca56c19dd76be242759"

DESCRIPTION="Easy to integrate Vulkan memory allocation library"
HOMEPAGE="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator"
SRC_URI="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/${COMMIT_HASH}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

IUSE="doc examples"

BDEPEND="doc? ( dev-python/sphinx )"
RDEPEND="media-libs/vulkan-loader"

RESTRICT="mirror"

S="${WORKDIR}/VulkanMemoryAllocator-${COMMIT_HASH}"

src_configure() {
	local mycmakeargs=(
		-DVMA_BUILD_DOCUMENTATION="$(usex doc)"
		-DVMA_BUILD_SAMPLES="$(usex examples)"
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr/include/vma"
	)
	CMAKE_BUILD_TYPE=Release
	cmake_src_configure
}
