# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Codec for the Ultra HDR format"
HOMEPAGE="https://github.com/google/libultrahdr"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/google/libultrahdr"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://github.com/google/libultrahdr/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="benchmark doc examples +egl test +iso +xmp cpu_flags_x86_avx cpu_flags_x86_sse4_2"

DEPEND="
	egl? ( media-libs/mesa[egl(+)] )
	xmp? ( >=media-libs/exempi-2.1.0:= )
	iso? ( >=sys-libs/libosinfo-1.10.0-r1 )
"

BDEPEND="
	virtual/libc
	virtual/pkgconfig
	app-alternatives/ninja
	dev-build/cmake
	doc? (
		app-text/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx[latex]
	)
"

REUIRED_USE="
	|| ( xmp iso )
"

RESTRICT="
	mirror
	!test? ( test )
"

PATCHES=(
#	"${FILESDIR}/010-libultrahdr-use-system-libjpeg.patch"
#	"${FILESDIR}/020-libultrahdr-build-shared-library.patch"
)

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE='Release'
	local mycmakeargs=(
		-DUHDR_BUILD_EXAMPLES="$(usex examples)"
		-DUHDR_BUILD_TESTS="$(usex test)"
		-DUHDR_BUILD_BENCHMARK="$(usex benchmark)"
		-DUHDR_BUILD_DEPS=NO
		-DUHDR_ENABLE_GLES="$(usex egl)"
		-DUHDR_WRITE_XMP="$(usex xmp)"
		-DUHDR_WRITE_ISO="$(usex iso)"
	)
	if use cpu_flags_x86_avx || use cpu_flags_x86_sse4_2; then
		mycmakeargs+=(
			-DUHDR_ENABLE_INTRINSICS="yes"
		)
	fi
	cmake_src_configure
}

