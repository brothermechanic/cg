# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 )
WEBAPP_OPTIONAL=yes
WEBAPP_MANUAL_SLOT=yes

inherit cmake flag-o-matic java-pkg-opt-2 python-single-r1 qmake-utils toolchain-funcs virtualx webapp

# Short package version
SPV="$(ver_cut 1-2)"

DESCRIPTION="The Visualization Toolkit"
HOMEPAGE="https://www.vtk.org/"
SRC_URI="
	https://vtk.org/files/release/${SPV}/VTK-${PV}.tar.gz
	doc? ( https://vtk.org/files/release/${SPV}/vtkDocHtml-${PV}.tar.gz )
	examples? (
		https://vtk.org/files/release/${SPV}/VTKData-${PV}.tar.gz
		https://vtk.org/files/release/${SPV}/VTKLargeData-${PV}.tar.gz
	)"

LICENSE="BSD LGPL-2"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="
	all-modules aqua boost doc examples imaging ffmpeg gdal java json mpi
	mysql odbc offscreen postgres python qt5 rendering tbb theora
	video_cards_nvidia views web R +X xdmf2"

REQUIRED_USE="
	all-modules? ( python xdmf2 boost )
	java? ( qt5 )
	python? ( ${PYTHON_REQUIRED_USE} )
	examples? ( python )
	web? ( python )
	^^ ( X aqua offscreen )"

RDEPEND="
	app-arch/lz4
	dev-db/sqlite
	dev-libs/double-conversion:=
	dev-libs/expat
	dev-libs/jsoncpp:=
	dev-libs/libxml2:2
	>=dev-libs/pugixml-1.9
	>=media-libs/freetype-2.5.4
	media-libs/glew:0=
	>=media-libs/libharu-2.3.0-r2
	media-libs/libpng:0=
	media-libs/libtheora
	media-libs/mesa
	media-libs/tiff:0
	sci-libs/exodusii
	sci-libs/hdf5:=
	sci-libs/netcdf-cxx:3
	sys-libs/zlib
	virtual/jpeg:0
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXmu
	x11-libs/libXt
	boost? ( dev-libs/boost:=[mpi?] )
	examples? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
	)
	ffmpeg? ( virtual/ffmpeg )
	gdal? ( sci-libs/gdal )
	java? ( >=virtual/jdk-1.7:* )
	mpi? (
		virtual/mpi[cxx,romio]
		python? ( dev-python/mpi4py )
	)
	mysql? ( virtual/mysql )
	odbc? ( dev-db/unixODBC )
	offscreen? ( media-libs/mesa[osmesa] )
	postgres? ( dev-db/postgresql:= )
	python? (
		${PYTHON_DEPS}
		dev-python/sip
	)
	qt5? (
		dev-qt/designer:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtopengl:5
		dev-qt/qtsql:5
		dev-qt/qtwebkit:5
		dev-qt/qtx11extras:5
		python? ( dev-python/PyQt5 )
	)
	R? ( dev-lang/R )
	tbb? ( dev-cpp/tbb )
	video_cards_nvidia? ( x11-drivers/nvidia-drivers[tools,static-libs] )
	web? (
		${WEBAPP_DEPEND}
		dev-python/autobahn
		dev-python/constantly
		dev-python/hyperlink
		dev-python/incremental
		dev-python/six
		dev-python/twisted
		dev-python/txaio
		dev-python/zope-interface
	)
	xdmf2? ( sci-libs/xdmf2 )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

PATCHES=(
	"${FILESDIR}/${P}-libdir.patch"
	"${FILESDIR}/${P}-fix-designer-plugin-install-dir.patch"
)

S="${WORKDIR}"/VTK-${PV}

RESTRICT="test"
CMAKE_BUILD_TYPE="Release"

pkg_setup() {
	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
	use web && webapp_pkg_setup
}

src_prepare() {
	local x
	# missing: VPIC freerange sqlite utf8 verdict xmdf2 xmdf3
	for x in expat freetype glew hdf5 jpeg jsoncpp libharu libxml2 lz4 mpi4py netcdf png tiff zlib; do
		ebegin "Dropping bundled ${x}"
		rm -r ThirdParty/${x}/vtk${x} || die
		eend $?
	done

	if use doc; then
		einfo "Removing .md5 files from documents."
		rm -f "${WORKDIR}"/html/*.md5 || die "Failed to remove superfluous hashes"
		sed -e "s|\${VTK_BINARY_DIR}/Utilities/Doxygen/doc|${WORKDIR}|" \
			-i Utilities/Doxygen/CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure() {
	# general configuration
	local mycmakeargs=(
		-Wno-dev
		-DVTK_INSTALL_LIBRARY_DIR=$(get_libdir)
		-DVTK_INSTALL_DOC_DIR="${EPREFIX}/usr/share/doc/${PF}"
		-DVTK_DATA_ROOT="${EPREFIX}/usr/share/${PN}/data"
		-DVTK_CUSTOM_LIBRARY_SUFFIX=""
		-DVTK_FORBID_DOWNLOADS=ON
		-DVTK_GENERATE_MODULES_JSON=ON
		-DBUILD_SHARED_LIBS=ON
		-DVTK_USE_SYSTEM_EXPAT=ON
		-DVTK_USE_SYSTEM_FREETYPE=ON
		# Use bundled gl2ps (bundled version is a patched version of 1.3.9. Post 1.3.9 versions should be compatible)
		-DVTK_USE_SYSTEM_GL2PS=OFF
		-DVTK_USE_SYSTEM_GLEW=ON
		-DVTK_USE_SYSTEM_HDF5=ON
		-DVTK_USE_SYSTEM_JPEG=ON
		# only support proj-4 which conflicts with several other packages requiring >=proj-{5,6}
		-DVTK_USE_SYSTEM_LIBPROJ=OFF
		-DVTK_USE_SYSTEM_LIBXML2=ON
		-DVTK_USE_SYSTEM_MPI4PY=ON
		-DVTK_USE_SYSTEM_NETCDF=ON
		-DVTK_USE_SYSTEM_PNG=ON
		-DVTK_USE_SYSTEM_SIX=ON
		-DVTK_USE_SYSTEM_TIFF=ON
		-DVTK_USE_SYSTEM_XDMF2=OFF
		-DVTK_USE_SYSTEM_ZLIB=ON
		-DVTK_USE_SYSTEM_LIBRARIES=ON
		# Use bundled diy2 (no gentoo package / upstream does not provide a Finddiy2.cmake or diy2Config.cmake / diy2-config.cmake)
		-DVTK_USE_SYSTEM_DIY2=OFF
		-DVTK_USE_LARGE_DATA=ON
		-DVTK_EXTRA_COMPILER_WARNINGS=ON
		-DVTK_Group_StandAlone=ON
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_EXAMPLES=$(usex examples)
		-DVTK_BUILD_ALL_MODULES=$(usex all-modules)
		-DVTK_Group_Imaging=$(usex imaging)
		-DVTK_Group_MPI=$(usex mpi)
		-DVTK_Group_Rendering=$(usex rendering)
		-DVTK_Group_Views=$(usex views)
		-DVTK_Group_Web=$(usex web)
		-DVTK_WWW_DIR="${ED%/}/${MY_HTDOCSDIR}"
		-DVTK_WRAP_JAVA=$(usex java)
		-DVTK_WRAP_PYTHON=$(usex python)
		-DModule_vtkInfovisBoost=$(usex boost)
		-DModule_vtkInfovisBoostGraphAlgorithms=$(usex boost)
		-DModule_vtkIOODBC=$(usex odbc)
		-DVTK_USE_OFFSCREEN=$(usex offscreen)
		-DVTK_OPENGL_HAS_OSMESA=$(usex offscreen)
		-DVTK_USE_OGGTHEORA_ENCODER=$(usex theora)
		-DVTK_USE_NVCONTROL=$(usex video_cards_nvidia)
		-DVTK_USE_X=$(usex X)
	# IO
		-DVTK_USE_FFMPEG_ENCODER=$(usex ffmpeg)
		-DModule_vtkIOGDAL=$(usex gdal)
		-DModule_vtkIOGeoJSON=$(usex json)
		-DModule_vtkIOXdmf2=$(usex xdmf2)
		-DBUILD_TESTING=$(usex examples)
	# Apple stuff, does it really work?
		-DVTK_USE_COCOA=$(usex aqua)
	)

	if use java; then
		local javacargs=$(java-pkg_javac-args)
		mycmakeargs+=( -DJAVAC_OPTIONS=${javacargs// /;} )
	fi

	if use tbb; then
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="TBB" )
	else
		mycmakeargs+=( -DVTK_SMP_IMPLEMENTATION_TYPE="Sequential" )
	fi

	if use python; then
		mycmakeargs+=(
			-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
			-DPYTHON_LIBRARY="$(python_get_library_path)"
			-DVTK_USE_SYSTEM_SIX=ON
		)
	fi

	if use qt5; then
		mycmakeargs+=(
			-DVTK_INSTALL_QT_DIR="$(qt5_get_libdir)/qt5/plugins/designer"
			-DVTK_QT_VERSION=5
			-DQT_MOC_EXECUTABLE="$(qt5_get_bindir)/moc"
			-DQT_UIC_EXECUTABLE="$(qt5_get_bindir)/uic"
			-DQT_QMAKE_EXECUTABLE="$(qt5_get_bindir)/qmake"
			-DVTK_Group_Qt:BOOL=ON
		)
	fi

	append-cppflags -D__STDC_CONSTANT_MACROS -D_UNICODE

	use java && export JAVA_HOME="${EPREFIX}/etc/java-config-2/current-system-vm"

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif90
		export F90=mpif90
		export F77=mpif77
	fi

	cmake_src_configure
}

src_install() {
	use web && webapp_src_preinst

	cmake_src_install

	use java && java-pkg_regjar "${ED%/}"/usr/$(get_libdir)/${PN}.jar

	# Stop web page images from being compressed
	use doc && docompress -x /usr/share/doc/${PF}/doxygen

	# install examples
	if use examples; then
		einfo "Installing examples"
		mv -v {E,e}xamples || die
		dodoc -r examples
		docompress -x /usr/share/doc/${PF}/examples
	fi

	# environment
	cat >> "${T}"/40${PN} <<- EOF || die
		VTK_DATA_ROOT=${EPREFIX}/usr/share/${PN}/data
		VTK_DIR=${EPREFIX}/usr/$(get_libdir)/${PN}-${SPV}
		VTKHOME=${EPREFIX}/usr
		EOF
	doenvd "${T}"/40${PN}

	use web && webapp_src_install
}

# webapp.eclass exports these but we want it optional #534036
pkg_postinst() {
	use web && webapp_pkg_postinst
}

pkg_prerm() {
	use web && webapp_pkg_prerm
}
