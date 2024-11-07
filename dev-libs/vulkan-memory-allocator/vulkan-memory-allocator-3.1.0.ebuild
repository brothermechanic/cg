# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Easy to integrate Vulkan memory allocation library"
HOMEPAGE="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator"
#SHA="05973d8aeb1a4d12f59aadfb86d20decadba82d1"
SRC_URI="https://github.com/GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="media-libs/vulkan-loader"
RDEPEND="${DEPEND}"

IUSE="doc examples"

RESTRICT="mirror"

BDEPEND="doc? ( app-text/doxygen )"

S="${WORKDIR}/VulkanMemoryAllocator-${PV}"

src_configure() {
	local mycmakeargs=(
		-DVMA_BUILD_DOCUMENTATION=$(usex doc)
		-DVMA_BUILD_SAMPLES=$(usex examples)
		-DCMAKE_INSTALL_INCLUDEDIR="${EPREFIX}/usr/include/vma"
	)

	cmake_src_configure
}
