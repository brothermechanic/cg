# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )
inherit cmake python-any-r1 toolchain-funcs

# See also https://github.com/KhronosGroup/OpenXR-SDK-Source/blob/release-1.1.62/.reuse/dep5
MY_PN="OpenXR-SDK-Source"
DESCRIPTION="Generated headers and sources for OpenXR loader"
HOMEPAGE="https://khronos.org/openxr"
SRC_URI="https://github.com/KhronosGroup/OpenXR-SDK-Source/archive/release-${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-release-${PV}"
LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2 ${PV})"
KEYWORDS="amd64"
NV_DRIVER_VERSION_VULKAN="610.43"
IUSE="doc gles2 +system-jsoncpp video_cards_amdgpu test video_cards_intel
video_cards_nvidia video_cards_radeonsi test wayland xcb X"
REQUIRED_USE+="
	^^ (
		xcb
		X
		wayland
	)
	|| (
		video_cards_amdgpu
		video_cards_intel
		video_cards_nvidia
		video_cards_radeonsi
	)
"
DEPEND+="
	${PYTHON_DEPS}
	media-libs/mesa[libglvnd(+)]
	media-libs/vulkan-loader
	virtual/libc
	system-jsoncpp? (
		dev-libs/jsoncpp
	)
	xcb? (
		x11-libs/libxcb
		x11-libs/xcb-util-keysyms
		x11-libs/xcb-util-wm
	)
	X? (
		x11-base/xorg-proto
		x11-libs/libX11
	)
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
		dev-util/wayland-scanner
		media-libs/mesa[egl(+)]
	)
	|| (
		video_cards_amdgpu? (
			media-libs/mesa[video_cards_radeonsi,vulkan]
			x11-base/xorg-drivers[video_cards_amdgpu]
		)
		video_cards_intel? (
			media-libs/mesa[video_cards_intel,vulkan]
			x11-base/xorg-drivers[video_cards_intel]
		)
		video_cards_nvidia? (
			>=x11-drivers/nvidia-drivers-${NV_DRIVER_VERSION_VULKAN}
		)
		video_cards_radeonsi? (
			media-libs/mesa[video_cards_radeonsi,vulkan]
			x11-base/xorg-drivers[video_cards_radeonsi]
		)
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep '>=dev-python/jinja2-3.0.3[${PYTHON_USEDEP}]')
	>=dev-build/cmake-3.0
	virtual/pkgconfig
	|| (
		llvm-core/clang
		sys-devel/gcc
	)
"
RESTRICT="
	!test ( test )
	mirror
"

src_configure() {
	CMAKE_BUILD_TYPE="Release"
	export CC=$(tc-getCC)
	export CXX=$(tc-getCXX)
	mycmakeargs=(
		-DBUILD_API_LAYERS=OFF
		-DBUILD_CONFORMANCE_TESTS=$(usex test $(usex X ON OFF) OFF)
		-DBUILD_TESTS=$(usex test)
		-DBUILD_WITH_SYSTEM_JSONCPP=$(usex system-jsoncpp)
	)
	if use X ; then
		mycmakeargs+=( -DPRESENTATION_BACKEND=xlib )
	elif use xcb ; then
		mycmakeargs+=( -DPRESENTATION_BACKEND=xcb )
	elif use wayland ; then
		mycmakeargs+=( -DPRESENTATION_BACKEND=wayland )
	else
		die "Must choose a PRESENTATION_BACKEND"
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install
	docinto licenses
	dodoc .reuse/dep5
	dodoc LICENSES/*
	dodoc COPYING.adoc
	mv "${ED}/usr/share/doc/${PN}/LICENSE" \
		"${ED}/usr/share/doc/${PN}-${PVR}/licenses" || die
	rm -rf "${ED}/usr/share/doc/${PN}" || die
	if use doc ; then
		docinto readmes
		dodoc CHANGELOG.SDK.md
		mv "${ED}/usr/share/doc/${P}/README.md" \
			"${ED}/usr/share/doc/${P}/readmes" || die
	else
		rm -rf "${ED}/usr/share/doc/${P}/README.md"
	fi
}
