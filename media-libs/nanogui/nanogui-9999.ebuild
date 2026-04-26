# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit cmake-multilib python-single-r1

DESCRIPTION="Minimalistic C++/Python GUI library"
HOMEPAGE="https://github.com/mitsuba-renderer/nanogui"

if [[ ${PV} =~ 9999 ]] ; then
	EGIT_REPO_URI="https://github.com/mitsuba-renderer/nanogui.git"
	inherit git-r3
else
	GLFW_COMMIT="38f86be2c9495a4aaacbf5360c0f79f729576a9d"
	NANOVG_COMMIT="0319c4375341973b8c1da255a6660cf05797fae7"
	NANOGUI_COMMIT="ca438c315df9996174f50052909cb7f1375cb798"
	NATIVEFILEDIALOG_EXTENDED_COMMIT="28c751212d345ca77f91feb23663c8b7dc3ef5f2"
	SRC_URI="
		https://github.com/mitsuba-renderer/nanogui/archive/${NANOGUI_COMMIT}.tar.gz -> ${P}-${NANOGUI_COMMIT:0:7}.tar.gz
		https://github.com/wjakob/nanovg/archive/${NANOVG_COMMIT}.tar.gz -> nanovg-${NANOVG_COMMIT:0:7}.tar.gz
		https://github.com/wjakob/glfw/archive/${GLFW_COMMIT}.tar.gz -> glfw-${GLFW_COMMIT:0:7}.tar.gz
		https://github.com/mitsuba-renderer/nativefiledialog-extended/archive/${NATIVEFILEDIALOG_EXTENDED_COMMIT}.tar.gz -> nativefiledialog-extended-${NATIVEFILEDIALOG_EXTENDED_COMMIT:0:7}.tar.gz
	"
	KEYWORDS="amd64 x86 arm arm64"
	S="${WORKDIR}/${PN}-${NANOGUI_COMMIT}"
fi

LICENSE="ZLIB"
SLOT="0"
IUSE="X doc javascript examples python test"

DEPEND="
	dev-libs/stb:=
	>=media-libs/libglvnd-1.3.2[X?,${MULTILIB_USEDEP}]
	media-libs/glfw:0[X?,${MULTILIB_USEDEP}]
"
BDEPEND="
	>=dev-build/cmake-3.16
	python? ( dev-python/nanobind )
	javascript? ( dev-util/emscripten )
	doc? ( app-text/doxygen[dot] )
	virtual/pkgconfig
"
REQUIRED_USE="
	python? (
		${PYTHON_REQUIRED_USE}
	)
"
RESTRICT="
	mirror
	!test? ( test )
"
QA_PRESTRIPPED="usr/lib/python.*/site-packages/.*"

PATCHES=(
	"${FILESDIR}/${PN}-0.2.0-fix-include-for-GLES3-opengl.patch"
)

src_unpack(){
	if [[ ${PV} =~ 9999 ]] ; then
		git-r3_fetch
		git-r3_checkout
	else
		unpack ${A}
		rm -r "${S}/ext/glfw" || die
		ln -snf "${WORKDIR}/glfw-${GLFW_COMMIT}" "${S}/ext/glfw" || die
		rm -r "${S}/ext/nanovg" || die
		ln -snf "${WORKDIR}/nanovg-${NANOVG_COMMIT}" "${S}/ext/nanovg" || die
		rm -r "${S}/ext/nativefiledialog-extended" || die
		ln -snf "${WORKDIR}/nativefiledialog-extended-${NATIVEFILEDIALOG_EXTENDED_COMMIT}" "${S}/ext/nativefiledialog-extended" || die
	fi
}

src_prepare() {
	# Allow build with system glfw
	# sed -e 's|NOT IS_DIRECTORY .*/ext/glfw/src"|FALSE|' \
	#	-e 's| PRE_BUILD||g' \
	sed -e 's|add_subdirectory(\${NANOGUI_NANOBIND_DIR} ext\/nanobind)|find_package(nanobind CONFIG REQUIRED)|' \
		-i CMakeLists.txt || die
	# Fix glvnd library link GLESv3, which is GLESv2 on mesa
	sed -e 's|\(list(APPEND NANOGUI_LIBS GLESv\)3)|\12)|' -i CMakeLists.txt || die
	sed -e "s|\${CMAKE_INSTALL_LIBDIR\}|$(python_get_sitedir)|" -i src/python/CMakeLists.txt || die
	cmake_src_prepare
}

src_configure() {
	abi_configure() {
		use javascript && CMAKE_C_COMPILER=emcc
		local mycmakeargs=(
			-DCMAKE_POLICY_DEFAULT_CMP0148="OLD"
			-DCMAKE_POLICY_VERSION_MINIMUM=3.5
			#-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
			-DCMAKE_INSTALL_DOCDIR=/usr/share/doc/"${PF}"
			-Dnanobind_DIR="$(python_get_sitedir)/nanobind/cmake"
			-DNANOGUI_BUILD_EXAMPLES=$(usex examples)
			-DNANOGUI_BUILD_SHARED=ON
			-DNANOGUI_BUILD_PYTHON=$(usex python)
			-DNANOGUI_BUILD_GLAD=OFF
			-DNANOGUI_BUILD_GLFW=OFF
			-DNANOGUI_BACKEND="$(usex X "OpenGl" "GLES 3")"
		)
		CMAKE_BUILD_TYPE=Release
		cmake_src_configure
	}
	multilib_parallel_foreach_abi abi_configure
}
