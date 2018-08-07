# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
	CMAKE_IN_SOURCE_BUILD="true"

PYTHON_COMPAT=( python{2_7,3_6})

inherit cmake-utils eutils fdo-mime fortran-2 python-single-r1

DESCRIPTION="QT based Computer Aided Design application"
HOMEPAGE="http://www.freecadweb.org/"

if [[ ${PV} == *99999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/FreeCAD/FreeCAD.git"
else
	SRC_URI="https://github.com/FreeCAD/FreeCAD/archive/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

#sci-libs/orocos_kdl waiting for Bug 604130 (keyword ~x86)
#dev-qt/qtgui:4[-egl] and dev-qt/qtopengl:4[-egl] : Bug 564978
#dev-python/pyside[svg] : Bug 591012
COMMON_DEPEND="
	${PYTHON_DEPS}
	dev-cpp/eigen:3
	dev-libs/boost:=[python,${PYTHON_USEDEP}]
	dev-libs/xerces-c[icu]
	dev-python/matplotlib[${PYTHON_USEDEP}]
	dev-python/pyside:2[svg,${PYTHON_USEDEP}]
	dev-python/shiboken:2[${PYTHON_USEDEP}]
	dev-qt/designer:5
	dev-qt/qtgui:5
	dev-qt/qtopengl:5
	dev-qt/qtsvg:5
	dev-qt/qtwebkit:5
	media-libs/coin
	media-libs/freetype
	|| ( sci-libs/opencascade:7.3.0[vtk] )
	sys-libs/zlib
	virtual/glu
	sci-libs/libmed"
#	dev-java/xerces

RDEPEND="${COMMON_DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-qt/assistant:5"
#	dev-python/pivy[${PYTHON_USEDEP}]

DEPEND="${COMMON_DEPEND}
	>=dev-lang/swig-2.0.4-r1:0
	dev-python/pyside-tools:2[${PYTHON_USEDEP}]"

PATCHES=(
	"${FILESDIR}"/fix_path.patch
)

# https://bugs.gentoo.org/show_bug.cgi?id=352435
# https://www.gentoo.org/foundation/en/minutes/2011/20110220_trustees.meeting_log.txt
RESTRICT="mirror"

# TODO:
#   DEPEND and RDEPEND:
#		salome-smesh - science overlay
#		zipio++ - not in portage yet

DOCS=( README.md ChangeLog.txt )

pkg_setup() {
	fortran-2_pkg_setup
	python-single-r1_pkg_setup

	[[ -z ${CASROOT} ]] && die "empty \$CASROOT, run eselect opencascade set or define otherwise"
}

src_unpack() {
	unpack ${A}
	mv FreeCAD-0.17 freecad-0.17
}

src_configure() {
	export QT_SELECT=5

	#-DOCC_* defined with cMake/FindOpenCasCade.cmake
	#-DCOIN3D_* defined with cMake/FindCoin3D.cmake
	#-DSOQT_ not used
	#-DFREECAD_USE_EXTERNAL_KDL="ON" waiting for Bug 604130 (keyword ~x86)
	local mycmakeargs=(
		-DBUILD_QT5=ON
		-DCXXFLAGS="-D_OCC64"
		-DCMAKE_IN_SOURCE_BUILD=1
		-D_RESPECT_CMAKE_BUILD_DIR=1
		-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
		-DOCC_LIBRARY_DIR="${CASROOT}"/lib
		-DOPENMPI_INCLUDE_DIRS=/usr/include
		-DCMAKE_INSTALL_DATADIR=usr/share/${P}
		-DCMAKE_INSTALL_DOCDIR=usr/share/doc/${PF}
		-DCMAKE_INSTALL_INCLUDEDIR=include/${P}
		-DFREECAD_USE_EXTERNAL_KDL="OFF"
#		$(enable_module addonmgr)
#		$(enable_module arch)
#		$(enable_module assembly)
#		$(enable_module complete)
#		$(enable_module draft)
#		$(enable_module drawing)
#		$(enable_module fem)
#		$(enable_module idf)
#		$(enable_module image)
#		$(enable_module import)
#		$(enable_module inspection)
#		$(enable_module jtreader)
#		$(enable_module material)
#		$(enable_module mesh)
#		$(enable_module mesh_part)
#		$(enable_module openscad)
#		$(enable_module part)
#		$(enable_module part_design)
#		$(enable_module path)
#		$(enable_module plot)
#		$(enable_module points)
#		$(enable_module raytracing)
#		$(enable_module reverseengineering)
#		$(enable_module robot)
#		$(enable_module sandbox)
#		$(enable_module ship)
#		$(enable_module show)
#		$(enable_module sketcher)
#		$(enable_module smesh)
#		$(enable_module spreadsheet)
#		$(enable_module start)
#		$(enable_module surface)
#		$(enable_module techdraw)
#		$(enable_module template)
#		$(enable_module test)
#		$(enable_module tux)
#		$(enable_module web)
	)

	# TODO to remove embedded dependencies:
	#
	#	-DFREECAD_USE_EXTERNAL_ZIPIOS="ON" -- this option needs zipios++ but it's not yet in portage so the embedded zipios++
	#                (under src/zipios++) will be used
	#	salomesmesh is in 3rdparty but upstream's find_package function is not complete yet to compile against external version
	#                (external salomesmesh is available in "science" overlay)

	cmake-utils_src_configure
	einfo "${P} will be built against opencascade version ${CASROOT}"
}

src_install() {
	#doins usr
	cmake-utils_src_install
	doins -r usr || cd fre

	make_desktop_entry FreeCAD "FreeCAD" "" "" "MimeType=application/x-extension-fcstd;"

	# install mimetype for FreeCAD files
	insinto /usr/share/mime/packages
	# nextlline failes: 
	#newins "${FILESDIR}"/${PN}.sharedmimeinfo "${PN}.xml"

	# install icons to correct place rather than /usr/share/freecad
	# next lines fail:
	#pushd ${WORKDIR}/${PF}_build/share/${P} || die
	##local size
	#for size in 16 32 48 64; do
	#	newicon -s ${size} freecad-icon-${size}.png freecad.png
	#done
	#doicon -s scalable freecad.svg
	#newicon -s 64 -c mimetypes freecad-doc.png application-x-extension-fcstd.png
	#popd || die

	python_optimize "${ED%/}"/usr/{,share/${P}/}Mod/
}

pkg_postinst() {
	fdo-mime_mime_database_update
}

pkg_postrm() {
	fdo-mime_mime_database_update
}
 
