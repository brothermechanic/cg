# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7..9} )

inherit cmake flag-o-matic python-single-r1

DESCRIPTION="A color management framework for visual effects and animation"
HOMEPAGE="https://opencolorio.org/"
SRC_URI="https://github.com/imageworks/OpenColorIO/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenColorIO-${PV}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~ppc64 x86"
IUSE="cpu_flags_x86_sse2 doc opengl python static-libs test"
REQUIRED_USE="
	doc? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	dev-cpp/pystring
	dev-python/pybind11
	media-libs/ilmbase
	>=dev-cpp/yaml-cpp-0.5
	dev-libs/tinyxml
	opengl? (
		media-libs/lcms:2
		media-libs/openimageio
		media-libs/glew:=
		media-libs/freeglut
		virtual/opengl
	)
	python? ( ${PYTHON_DEPS} )
"

DEPEND="${RDEPEND}"
BDEPEND="
	>=dev-util/cmake-3.16.2-r1
	virtual/pkgconfig
	doc? (
		$(python_gen_cond_dep '
			dev-python/sphinx[${PYTHON_USEDEP}]
		')
	)
"

# Restricting tests, bugs #439790 and #447908
RESTRICT="mirror test"

CMAKE_BUILD_TYPE=Release

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	#use python && python_fix_shebang .
	sed -i -e "s|LIBRARY DESTINATION lib|LIBRARY DESTINATION $(get_libdir)|g" {,src/bindings/python/,src/OpenColorIO/,src/libutils/oiiohelpers/,src/libutils/oglapphelpers/}CMakeLists.txt || die
	sed -i -e "s|ARCHIVE DESTINATION lib|ARCHIVE DESTINATION $(get_libdir)|g" {,src/bindings/python/,src/OpenColorIO/,src/libutils/oiiohelpers/,src/libutils/oglapphelpers/}CMakeLists.txt || die
	rm docs/CMakeLists.txt
}

src_configure() {
	# Missing features:
	# - Truelight and Nuke are not in portage for now, so their support are disabled
	# - Java bindings was not tested, so disabled
	# Notes:
	# - OpenImageIO is required for building ociodisplay and ocioconvert (USE opengl)
	# - OpenGL, GLUT and GLEW is required for building ociodisplay (USE opengl)
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/"
		-DOCIO_BUILD_NUKE=OFF
		-DBUILD_SHARED_LIBS=ON
		-DOCIO_BUILD_STATIC=$(usex static-libs)
		-DOCIO_BUILD_DOCS=$(usex doc)
		-DOCIO_BUILD_APPS=$(usex opengl)
		-DOCIO_BUILD_PYTHON=$(usex python)
		-DOCIO_BUILD_JAVA=OFF
		-DOCIO_USE_SSE=$(usex cpu_flags_x86_sse2)
		-DOCIO_BUILD_TESTS=$(usex test)
		-DOCIO_BUILD_GPU_TESTS=$(usex test)
		-DOCIO_BUILD_FROZEN_DOCS=$(usex doc)
		-DOCIO_INSTALL_EXT_PACKAGES=NONE
	)

	cmake_src_configure
}
