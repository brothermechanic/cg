# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit cmake dot-a flag-o-matic python-single-r1 virtualx

DESCRIPTION="Open Source API and interchange format for editorial timeline information"
HOMEPAGE="https://opentimeline.io"
if [[ "${PV}" == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/OpenTimelineIO.git"
	EGIT_SUBMODULES=( '*' )
	inherit git-r3
else
	MY_PN="OpenTimelineIO"
	MY_PV="${PV/_pre/.dev}"
	COMMIT="fc5c58e16f6832972cdb5c656dd8a6d87a4e5b02"
	SRC_URI="https://github.com/AcademySoftwareFoundation/OpenTimelineIO/archive/${COMMIT}.tar.gz -> ${P}-${COMMIT:0:7}.gh.tar.gz"
	S="${WORKDIR}/${MY_PN}-${COMMIT}"
	KEYWORDS="~amd64"
fi

IUSE="doc python static-libs test"
REQUIRED_USE="
	doc? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )
"

LICENSE="Apache-2.0"
SLOT="0"

DEPEND="
	dev-libs/rapidjson:=
	>=dev-libs/imath-3.1.4-r2:=
	>=sys-libs/minizip-ng-3.0.7
	virtual/zlib
	dev-libs/tinyxml
	dev-python/pybind11
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-alternatives/ninja
	>=dev-build/cmake-3.13
	virtual/pkgconfig
	python? (
		$(python_gen_cond_dep '>=dev-python/setuptools-42[${PYTHON_USEDEP}]')
	)
	doc? (
		app-text/doxygen
		$(python_gen_cond_dep '
			dev-python/breathe[${PYTHON_USEDEP}]
			dev-python/recommonmark[${PYTHON_USEDEP}]
			dev-python/six[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinx-press-theme[${PYTHON_USEDEP}]
			dev-python/sphinx-tabs[${PYTHON_USEDEP}]
			dev-python/testresources[${PYTHON_USEDEP}]
		')
	)
"

PATCHES=(
	"${FILESDIR}/${PN}-0.18.1-fix-deprecated-pybind11.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	#if [[ "${PV}" != "9999" ]]; then
	#	mv -T "${WORKDIR}/rapidjson-${RAPIDJSON_COMMIT}" "${S}/src/deps/rapidjson" || die
	#fi

	eapply_user

	sed -i "s|\(set(OTIO_RESOLVED_CXX_DYLIB_INSTALL_DIR \"\${CMAKE_INSTALL_PREFIX}/\)lib\")|\1$(get_libdir)\")|" \
		CMakeLists.txt || die

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DOTIO_FIND_IMATH=ON
		-DOTIO_FIND_PYBIND11=ON
		-DOTIO_FIND_RAPIDJSON=ON
		-DOTIO_FIND_MINIZIP_NG=ON
		-DOTIO_AUTOMATIC_SUBMODULES=OFF
		-DOTIO_FIND_IMATH=ON
		-DOTIO_CXX_COVERAGE=OFF
		-DOTIO_CXX_EXAMPLES=OFF
		-DOTIO_CXX_INSTALL=ON
		-DOTIO_DEPENDENCIES_INSTALL=ON
		-DOTIO_INSTALL_COMMANDLINE_TOOLS=ON
		-DOTIO_INSTALL_CONTRIB=OFF
		-DOTIO_PYTHON_INSTALL=OFF
		-DOTIO_SHARED_LIBS=ON
		-DBUILD_TESTING=$(usex test)
		-DOTIO_PYTHON_INSTALL=$(usex python)
	)

	use python && mycmakeargs+=(
		"-DPython_VERSION=${EPYTHON/python/}"
		"-DPython_EXECUTABLE=${PYTHON}"
		"-DOTIO_PYTHON_INSTALL_DIR=$(python_get_sitedir)"
	)

	cmake_src_configure
}

src_test() {
	[[ -c /dev/udmabuf ]] && addwrite /dev/udmabuf

	local myctestargs=(
		-j1
	)
	virtx cmake_src_test
}

src_install() {
	cmake_src_install

	if use doc; then
		# there are already files in ${ED}/usr/share/doc/${PF}
		mv "${ED}/usr/share/doc/OpenTimelineIO/"* "${ED}/usr/share/doc/${PF}" || die
		rmdir "${ED}/usr/share/doc/OpenTimelineIO" || die
	fi

	if use python; then
		python_optimize
	fi
}
