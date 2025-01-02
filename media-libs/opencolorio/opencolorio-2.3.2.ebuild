# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit cmake flag-o-matic python-single-r1 virtualx

DESCRIPTION="A color management framework for visual effects and animation"
HOMEPAGE="https://opencolorio.org https://github.com/AcademySoftwareFoundation/OpenColorIO"
SRC_URI="https://github.com/AcademySoftwareFoundation/OpenColorIO/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenColorIO-${PV}"

LICENSE="BSD"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="amd64 ~arm ~arm64 ~ppc64 ~riscv ~x86"
CPU_USE=(
	x86_{avx,avx2,avx512f,f16c,sse2,sse3,sse4_1,sse4_2,ssse3}
	arm_neon
)

IUSE="apps ${CPU_USE[@]/#/cpu_flags_} doc python static-libs test"
REQUIRED_USE="
	doc? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )
	test? ( apps )
"

RDEPEND="
	>=dev-cpp/pystring-1.1.3:=
	>=dev-cpp/yaml-cpp-0.7.0:=
	>=dev-libs/expat-2.4.1
	>=dev-libs/imath-3.1.4-r2:=
	>=sys-libs/minizip-ng-3.0.7
	>=sys-libs/zlib-1.2.13
	dev-libs/tinyxml
	dev-python/pybind11
	apps? (
		>=media-libs/openimageio-2.3.12.0-r3:=
		media-libs/lcms:2
		media-libs/freeglut
		media-libs/glew:=
		virtual/opengl
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep 'dev-python/pybind11[${PYTHON_USEDEP}]')
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-alternatives/ninja
	>=dev-build/cmake-3.13
	virtual/pkgconfig
	doc? (
		app-text/doxygen
		$(python_gen_cond_dep '
			dev-python/breathe[${PYTHON_USEDEP}]
			dev-python/expandvars[${PYTHON_USEDEP}]
			dev-python/recommonmark[${PYTHON_USEDEP}]
			dev-python/six[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinx-press-theme[${PYTHON_USEDEP}]
			dev-python/sphinx-tabs[${PYTHON_USEDEP}]
			dev-python/testresources[${PYTHON_USEDEP}]
		')
	)
	python? (
		$(python_gen_cond_dep '>=dev-python/setuptools-42[${PYTHON_USEDEP}]')
	)
	test? (
		>=media-libs/osl-1.11
		>=media-libs/openimageio-2.2.14
		media-libs/freeglut
		media-libs/glew:=
		media-libs/libglvnd
	)
"

# Restricting tests, bugs #439790 and #447908
RESTRICT="test"

PATCHES=(
	"${FILESDIR}/${PN}-2.2.1-adjust-python-installation.patch"
	"${FILESDIR}/${PN}-2.3.2-include-cstdint.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	sed -i -e "s|LIBRARY DESTINATION lib|LIBRARY DESTINATION $(get_libdir)|g" {,src/bindings/python/,src/OpenColorIO/,src/libutils/oglapphelpers/}CMakeLists.txt || die
	sed -i -e "s|ARCHIVE DESTINATION lib|ARCHIVE DESTINATION $(get_libdir)|g" {,src/bindings/python/,src/OpenColorIO/,src/libutils/oglapphelpers/}CMakeLists.txt || die

	# Avoid automagic test dependency on OSL, bug #833933
	# Can cause problems during e.g. OpenEXR unsplitting migration
	cmake_run_in tests cmake_comment_add_subdirectory osl
}

src_configure() {
	# Missing features:
	# - Truelight and Nuke are not in portage for now, so their support are disabled
	# - Java bindings was not tested, so disabled
	# Notes:
	# - OpenImageIO is required for building ociodisplay and ocioconvert (USE opengl)
	# - OpenGL, GLUT and GLEW is required for building ociodisplay (USE opengl)
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DOCIO_USE_ILMBASE=OFF
		-DOCIO_USE_OPENEXR_HALF=OFF
		-DBUILD_SHARED_LIBS=ON
		-DOCIO_BUILD_APPS=$(usex apps)
		-DOCIO_BUILD_DOCS=$(usex doc)
		-DOCIO_BUILD_FROZEN_DOCS=$(usex doc)
		-DOCIO_BUILD_GPU_TESTS=$(usex test)
		-DOCIO_BUILD_JAVA=OFF
		-DOCIO_BUILD_OPENFX=OFF # Not packaged yet
		-DOCIO_BUILD_PYTHON=$(usex python)
		-DOCIO_BUILD_STATIC=$(usex static-libs)
		-DOCIO_BUILD_TESTS=$(usex test)
		-DOCIO_INSTALL_EXT_PACKAGES=NONE
		-DOCIO_USE_SIMD=ON

	)

	if use amd64 || use x86 ; then
		mycmakeargs+=(
			"-DOCIO_USE_SSE2=$(usex cpu_flags_x86_sse2)"
			"-DOCIO_USE_SSE3=$(usex cpu_flags_x86_sse3)"
			"-DOCIO_USE_SSSE3=$(usex cpu_flags_x86_ssse3)"
			"-DOCIO_USE_SSE4=$(usex cpu_flags_x86_sse4_1)"
			"-DOCIO_USE_SSE42=$(usex cpu_flags_x86_sse4_2)"
			"-DOCIO_USE_AVX=$(usex cpu_flags_x86_avx)"
			"-DOCIO_USE_AVX2=$(usex cpu_flags_x86_avx2)"
			"-DOCIO_USE_AVX512=$(usex cpu_flags_x86_avx512f)"
			"-DOCIO_USE_F16C=$(usex cpu_flags_x86_f16c)"
		)
	fi

	# requires https://github.com/DLTcollab/sse2neon
	if use arm || use arm64 ; then
	 	mycmakeargs+=(
	 		"-DOCIO_USE_SSE2NEON=$(usex cpu_flags_arm_neon)"
	 	)
	fi

	use python && mycmakeargs+=(
		"-DOCIO_PYTHON_VERSION=${EPYTHON/python/}"
		"-DPython_EXECUTABLE=${PYTHON}"
		"-DPYTHON_VARIANT_PATH=$(python_get_sitedir)"
	)

	cmake_src_configure
}

src_test() {
	local myctestargs=(
		-j1
	)
	virtx cmake_src_test
}

src_install() {
	cmake_src_install

	if use doc; then
		# there are already files in ${ED}/usr/share/doc/${PF}
		mv "${ED}/usr/share/doc/OpenColorIO/"* "${ED}/usr/share/doc/${PF}" || die
		rmdir "${ED}/usr/share/doc/OpenColorIO" || die
	fi
}
