# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="MaterialX"
MY_P="${MY_PN}-${PV}"

PYTHON_COMPAT=( python3_{11..13} ) # CI does not list 3.10 for this package.
inherit cmake python-single-r1 desktop
if [[ ${PV} =~ 9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AcademySoftwareFoundation/MaterialX.git"
	EGIT_BRANCH="main"
	S="${WORKDIR}/${P}"
	KEYWORDS=""
else
	S="${WORKDIR}/${MY_P}"
	KEYWORDS="~amd64"
	# Needed for static link of viewer or graph-editor
	EGIT_GLFW_COMMIT="e130e55a990998c78fd323f21076e798e0efe8a4"
	EGIT_IMGUI_COMMIT="9aae45eb4a05a5a1f96be1ef37eb503a12ceb889"
	EGIT_IMGUI_NODE_EDITOR_COMMIT="e78e447900909a051817a760efe13fe83e6e1afc"
	EGIT_NANOBIND_COMMIT="07b4e1fc9e94eeaf5e9c2f4a63bdb275a25c82c6"
	EGIT_NANOGUI_COMMIT="f5020e2f3e5114d517642e67afbb21cb88cf04c0"
	EGIT_NANOVG_COMMIT="bf2320d1175122374a9b806d91e9e666c9336375"
	EGIT_NANOVG_METAL_COMMIT="075b04f16c579728c693b46a2ce408f2325968cf"
	EGIT_ROBIN_MAP_COMMIT="a603419b9a0687c9148e02c8bd5e3db180bb9ac0"
	SRC_URI="
		https://github.com/AcademySoftwareFoundation/MaterialX/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		viewer? (
			https://github.com/ocornut/imgui/archive/${EGIT_IMGUI_COMMIT}.tar.gz -> imgui-${EGIT_IMGUI_COMMIT:0:7}.tar.gz
			https://github.com/mitsuba-renderer/nanogui/archive/${EGIT_NANOGUI_COMMIT}.tar.gz -> nanogui-${EGIT_NANOGUI_COMMIT:0:7}.tar.gz
			https://github.com/wjakob/nanobind/archive/${EGIT_NANOBIND_COMMIT}.tar.gz -> nanobind-${EGIT_NANOBIND_COMMIT:0:7}.tar.gz
			https://github.com/wjakob/glfw/archive/${EGIT_GLFW_COMMIT}.tar.gz -> glfw-${EGIT_GLFW_COMMIT:0:7}.tar.gz
			https://github.com/wjakob/nanovg/archive/${EGIT_NANOVG_COMMIT}.tar.gz -> nanovg-${EGIT_NANOVG_COMMIT:0:7}.tar.gz
			https://github.com/wjakob/nanovg_metal/archive/${EGIT_NANOVG_METAL_COMMIT}.tar.gz -> nanovg_metal-${EGIT_NANOVG_METAL_COMMIT:0:7}.tar.gz
			https://github.com/Tessil/robin-map/archive/${EGIT_ROBIN_MAP_COMMIT}.tar.gz -> robin-map-${EGIT_ROBIN_MAP_COMMIT:0:7}.tar.gz
		)
		graph-editor? ( https://github.com/thedmd/imgui-node-editor/archive/${EGIT_IMGUI_NODE_EDITOR_COMMIT}.tar.gz -> imgui-node-editor-${EGIT_IMGUI_NODE_EDITOR_COMMIT:0:7}.tar.gz )
	"
fi

DESCRIPTION="MaterialX is an open standard for the exchange of rich material content."
HOMEPAGE="
https://materialx.org/
https://github.com/AcademySoftwareFoundation/MaterialX
"
LICENSE="
	Apache-2.0
	resources? ( CC0-1.0 )
	viewer? ( ZLIB MIT Boost-1.0 BSD )
	graph-editor? ( ZLIB MIT Boost-1.0 BSD )
"
SLOT="0/$(ver_cut 1-2)"
IUSE="X doc debug -examples graph-editor javascript lto openimageio +osl python +renderer resources test viewer"
REQUIRED_USE="
	python? (
		${PYTHON_REQUIRED_USE}
	)
	renderer? ( !osl? ( X ) )
	viewer? ( X )
	graph-editor? ( viewer )
"
DEPEND="
	media-libs/libglvnd[X?]
	virtual/libc
	openimageio? ( media-libs/openimageio )
	osl? ( >=media-libs/osl-1.11 )
	X? (
		x11-libs/libX11
		x11-libs/libXt
	)
	python? (
		$(python_gen_cond_dep '
			dev-python/pybind11[${PYTHON_USEDEP}]
			dev-python/nanobind[${PYTHON_USEDEP}]
		')
	)
"
BDEPEND="
	>=dev-build/cmake-3.16
	javascript? ( dev-util/emscripten )
	doc? ( app-text/doxygen[dot] )
"
RESTRICT="
	mirror
	!test ( test )
"

QA_PRESTRIPPED="usr/lib/python.*/site-packages/${MY_PN}/.*.so"

PATCHES=(
	"${FILESDIR}/materialx-1.38.9-setup.py-fix-sandbox-violation.patch"
	"${FILESDIR}/materialx-1.39.0-include-cstdint-gcc15-fix.patch"
)

pkg_setup() {
	use python && python_setup
}

src_unpack() {
	if [[ ${PV} =~ 9999 ]] ; then
		git-r3_fetch
		git-r3_checkout
	else
		unpack ${A}
		rm -r ${S}/source/PyMaterialX/External/PyBind11 || die
		if use viewer; then
			pushd "nanogui-${EGIT_NANOGUI_COMMIT}" || die
			rm -rf \
				"source/MaterialXView/NanoGUI/ext/nanovg" \
				"source/MaterialXView/NanoGUI/ext/nanovg_metal" \
				"source/MaterialXView/NanoGUI/ext/glfw" \
				"source/MaterialXView/NanoGUI/ext/nanobind" \
				|| die
			mv -T \
				"${WORKDIR}/nanovg-${EGIT_NANOVG_COMMIT}" \
				"ext/nanovg" \
				|| die
			mv -T \
				"${WORKDIR}/nanovg_metal-${EGIT_NANOVG_METAL_COMMIT}" \
				"ext/nanovg_metal" \
				|| die
			mv -T \
				"${WORKDIR}/glfw-${EGIT_GLFW_COMMIT}" \
				"ext/glfw" \
				|| die
			pushd "${WORKDIR}/nanobind-${EGIT_NANOBIND_COMMIT}" || die
				rm -rf \
					"ext/robin_map" \
					|| die
				mv "${WORKDIR}/robin-map-${EGIT_ROBIN_MAP_COMMIT}" \
					ext/robin_map \
					|| die
			popd
			mv -T \
				"${WORKDIR}/nanobind-${EGIT_NANOBIND_COMMIT}" \
				"ext/nanobind" \
				|| die
			popd || die

			pushd "${MY_P}" || die
			rm -rf \
				"source/MaterialXView/NanoGUI" \
				"source/MaterialXGraphEditor/External/ImGui" \
				"source/MaterialXGraphEditor/External/ImGuiNodeEditor" \
				|| die
			mv \
				"${WORKDIR}/nanogui-${EGIT_NANOGUI_COMMIT}" \
				"source/MaterialXView/NanoGUI" \
				|| die
			mv \
				"${WORKDIR}/imgui-${EGIT_IMGUI_COMMIT}" \
				"source/MaterialXGraphEditor/External/ImGui" \
				|| die
			mv \
				"${WORKDIR}/imgui-node-editor-${EGIT_IMGUI_NODE_EDITOR_COMMIT}" \
				"source/MaterialXGraphEditor/External/ImGuiNodeEditor" \
				|| die
			popd || die
		fi
	fi
}

src_prepare() {
	#sed -e "s/\(${CMAKE_BINARY_DIR}\)\/lib/\1\/$(get_libdir)/" -i CMakeLists.txt || die "Sed failed."
	sed -i 's|resources|/usr/share/materialx/resources|g' source/MaterialXView/{Main.cpp,Viewer.cpp} || die
	sed -i 's|"libraries"|"/usr/share/materialx/libraries"|g' source/MaterialXView/Main.cpp || die
	sed -i 's|resources|/usr/share/materialx/resources|g' source/MaterialXGraphEditor/{Main.cpp,Graph.cpp} || die
	sed -i 's|"libraries"|"/usr/share/materialx/libraries"|g' source/MaterialXGraphEditor/{Main.cpp,Graph.cpp} || die
	sed -i 's|"libraries"|"/usr/share/materialx/libraries"|g' source/MaterialXGenShader/GenOptions.h || die

	# Fix path in CMake module
	sed -e "s/\(@PACKAGE_CMAKE_INSTALL_PREFIX@\)\/libraries/\1\/share\/${PN}\/libraries/" \
		-e "s/\(@PACKAGE_CMAKE_INSTALL_PREFIX@\)\/resources/\1\/share\/${PN}\/resources/" \
		-e "s|\(@PACKAGE_CMAKE_INSTALL_PREFIX@\)\/python|\1\/$(python_get_sitedir)\/${PN}|" \
		-i cmake/modules/MaterialXConfig.cmake.in || die "Sed failed."

	# Do not install docs by default
	sed -e '/^    install(FILES LICENSE CHANGELOG.md README.md THIRD-PARTY.md DESTINATION .)$/d' -i CMakeLists.txt || die "Sed failed."
	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug 'Debug' 'Release')
	append-cppflags $(usex debug '-DDEBUG' '-DNDEBUG')
	addpredict /usr/lib/materialx

	local mycmakeargs=(
		-DCMAKE_POLICY_DEFAULT_CMP0148="OLD"
		-DMATERIALX_INSTALL_LIB_PATH="$(get_libdir)"
		-DMATERIALX_INSTALL_STDLIB_PATH="share/${PN}/libraries"
		-DMATERIALX_PYTHON_FOLDER_NAME="$(python_get_sitedir)/${MY_PN}"
		-DMATERIALX_BUILD_JS=$(usex javascript "ON" "OFF")
		-DMATERIALX_BUILD_DOCS=$(usex doc)
		-DMATERIALX_BUILD_OIIO=$(usex openimageio "ON" "OFF")
		-DMATERIALX_BUILD_PYTHON=$(usex python "ON" "OFF")
		-DMATERIALX_BUILD_RENDER=$(usex renderer "ON" "OFF")
		-DMATERIALX_BUILD_SHARED_LIBS=ON
		-DMATERIALX_BUILD_TESTS=$(usex test "ON" "OFF")
		-DMATERIALX_INSTALL_PYTHON=OFF
		-DMATERIALX_INSTALL_RESOURCES=$(usex resources "ON" "OFF")
		-DMATERIALX_BUILD_GRAPH_EDITOR=$(usex graph-editor "ON" "OFF")
		-DMATERIALX_BUILD_VIEWER=$(usex viewer "ON" "OFF")
	)
	if use renderer ; then
		mycmakeargs+=(
			-DMATERIALX_BUILD_GEN_GLSL=$(usex X)
			-DMATERIALX_BUILD_GEN_OSL=$(usex osl)
			-DMATERIALX_BUILD_GEN_MDL=$(usex X)
			-DMATERIALX_BUILD_GEN_MSL=$(usex X)
		)
	fi
	if use python ; then
		mycmakeargs+=(
			-Dpybind11_ROOT="$(python_get_sitedir)/pybind11"
			-DMATERIALX_PYTHON_EXECUTABLE="${PYTHON}"
			-DMATERIALX_PYTHON_VERSION="${EPYTHON/python/}"
			-DMATERIALX_PYTHON_LTO="$(usex lto)"
			-DPYTHON_EXECUTABLE="${PYTHON}"
		)
	fi
	cmake_src_configure
}

src_install() {
	DOCS=("LICENSE" "CHANGELOG.md" "README.md" "THIRD-PARTY.md")
	cmake_src_install
	# Remove garbage
	rm -rf "${ED}/var" || die
	# Add LDPATH to gentoo env
	echo "LDPATH=${EPREFIX}/usr/$(get_libdir)/${PN}/libraries" > 99-${PN}
	doenvd 99-${PN}
	# Desktop shortcuts
	use viewer && domenu "${FILESDIR}/materialx-view.desktop"
	use graph-editor && domenu "${FILESDIR}/materialx-grapheditor.desktop"
	if use viewer || use graph-editor; then
		mkdir -p ${D}/usr/share/icons/hicolor/256x256/apps
		cp documents/Images/MaterialXLogo_200x155.png ${D}/usr/share/icons/hicolor/256x256/apps/materialx.png
	fi

	use doc && einstalldocs

	if use python ; then
		if use examples ; then
			python_domodule "${ED}/usr/python/${MY_PN}"
			insinto "/usr/share/${PN}/python"
			doins -R "${ED}/usr/python/"
		fi
		rm -vrf "${ED}/usr/python/"
		# TODO: Check double install of shared shaders
		rm -vrf "${ED}/$(python_get_sitedir)/${MY_PN}/share"
	fi

	# Install resources
	use resources && mv ${ED}/usr/resources ${ED}/usr/share/${PN}/
	rm -vrf "${ED}/usr/resources"
}
