# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit check-reqs cmake-utils eutils flag-o-matic java-pkg-opt-2 multilib versionator

DESCRIPTION="Development platform for CAD/CAE, 3D surface/solid modeling and data exchange"
HOMEPAGE="http://www.opencascade.com/"
# convert version string x.x.x to x_x_x
MY_PV="$(replace_all_version_separators '_')"
SRC_URI="https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V${MY_PV};sf=tgz -> ${P}.tar.gz"

LICENSE="|| ( Open-CASCADE-LGPL-2.1-Exception-1.0 LGPL-2.1 )"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc examples freeimage gl2ps java tbb test +vtk"

RDEPEND="app-eselect/eselect-opencascade
	dev-lang/tcl:0=
	dev-lang/tk:0=
	dev-tcltk/itcl
	dev-tcltk/itk
	dev-tcltk/tix
	media-libs/freetype:2
	media-libs/ftgl
	virtual/glu
	virtual/opengl
	x11-libs/libXmu
	freeimage? ( media-libs/freeimage )
	gl2ps? ( x11-libs/gl2ps )
	java? ( >=virtual/jdk-0:= )
	tbb? ( dev-cpp/tbb )
	vtk? ( sci-libs/vtk[rendering] )"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

# https://bugs.gentoo.org/show_bug.cgi?id=352435
# https://www.gentoo.org/foundation/en/minutes/2011/20110220_trustees.meeting_log.txt
RESTRICT="bindist"

CHECKREQS_MEMORY="256M"
CHECKREQS_DISK_BUILD="3584M"

CMAKE_BUILD_TYPE=Release

S="${WORKDIR}/occt-V${MY_PV}"

PATCHES=(
	"${FILESDIR}"/ffmpeg4.patch
	"${FILESDIR}"/fix-install-dir-references.patch
	"${FILESDIR}"/vtk7.patch
	)

pkg_setup() {
	check-reqs_pkg_setup
	use java && java-pkg-opt-2_pkg_setup
}

src_prepare() {
	cmake-utils_src_prepare
	use java && java-pkg-opt-2_src_prepare
my_install_dir=${EROOT}usr/$(get_libdir)/${P}/ros
	local my_env_install="#!/bin/sh -f
if [ -z \"\$PATH\" ]; then
	export PATH=VAR_CASROOT/Linux/bin
else
	export PATH=VAR_CASROOT/Linux/bin:\$PATH
fi
if [ -z \"\$LD_LIBRARY_PATH\" ]; then
	export LD_LIBRARY_PATH=VAR_CASROOT/Linux/lib
else
	export LD_LIBRARY_PATH=VAR_CASROOT/Linux/lib:\$LD_LIBRARY_PATH
fi"
	local my_sys_lib=${EROOT}usr/$(get_libdir)
	local my_env="CASROOT=VAR_CASROOT
CSF_MDTVFontDirectory=VAR_CASROOT/src/FontMFT
CSF_LANGUAGE=us
MMGT_CLEAR=1
CSF_EXCEPTION_PROMPT=1
CSF_SHMessage=VAR_CASROOT/src/SHMessage
CSF_MDTVTexturesDirectory=VAR_CASROOT/src/Textures
CSF_XSMessage=VAR_CASROOT/src/XSMessage
CSF_StandardDefaults=VAR_CASROOT/src/StdResource
CSF_PluginDefaults=VAR_CASROOT/src/StdResource
CSF_XCAFDefaults=VAR_CASROOT/src/StdResource
CSF_StandardLiteDefaults=VAR_CASROOT/src/StdResource
CSF_GraphicShr=VAR_CASROOT/Linux/lib/libTKOpenGl.so
CSF_UnitsLexicon=VAR_CASROOT/src/UnitsAPI/Lexi_Expr.dat
CSF_UnitsDefinition=VAR_CASROOT/src/UnitsAPI/Units.dat
CSF_IGESDefaults=VAR_CASROOT/src/XSTEPResource
CSF_STEPDefaults=VAR_CASROOT/src/XSTEPResource
CSF_XmlOcafResource=VAR_CASROOT/src/XmlOcafResource
CSF_MIGRATION_TYPES=VAR_CASROOT/src/StdResource/MigrationSheet.txt
TCLHOME=${EROOT}usr/bin
TCLLIBPATH=${my_sys_lib}
ITK_LIBRARY=${my_sys_lib}/itk$(grep ITK_VER /usr/include/itk.h | sed 's/^.*"\(.*\)".*/\1/')
ITCL_LIBRARY=${my_sys_lib}/itcl$(grep ITCL_VER /usr/include/itcl.h | sed 's/^.*"\(.*\)".*/\1/')
TIX_LIBRARY=${my_sys_lib}/tix$(grep TIX_VER /usr/include/tix.h | sed 's/^.*"\(.*\)".*/\1/')
TK_LIBRARY=${my_sys_lib}/tk$(grep TK_VER /usr/include/tk.h | sed 's/^.*"\(.*\)".*/\1/')
TCL_LIBRARY=${my_sys_lib}/tcl$(grep TCL_VER /usr/include/tcl.h | sed 's/^.*"\(.*\)".*/\1/')"

	( 	echo "${my_env_install}"
		echo "${my_env}" | sed -e "s:^:export :" ) \
	| sed -e "s:VAR_CASROOT:${S}:g" > env.sh || die
	source env.sh

	(	echo "PATH=${my_install_dir}/bin"
		echo "LDPATH=${my_install_dir}/$(get_libdir)"
		echo "${my_env}" | sed \
			-e "s:VAR_CASROOT:${my_install_dir}:g" \
			-e "s:/Linux/lib/:/$(get_libdir)/:g" || die
	) > "${S}/50${PN}"

}

src_configure() {

	# from dox/dev_guides/building/cmake/cmake.md
	local mycmakeargs=(
		-DCMAKE_CONFIGURATION_TYPES="Gentoo"
		-DBUILD_WITH_DEBUG=$(usex debug)
		-DCMAKE_INSTALL_PREFIX="${my_install_dir}"
		-DINSTALL_DIR_DOC="/usr/share/doc/${P}"
		-DINSTALL_DIR_CMAKE="/usr/$(get_libdir)/cmake"
		-DUSE_D3D=no
		-DUSE_FREEIMAGE=$(usex freeimage)
		-DUSE_GL2PS=$(usex gl2ps)
		-DUSE_TBB=$(usex tbb)
		-DUSE_VTK=$(usex vtk)
		-DBUILD_DOC_Overview=$(usex doc)
		-DINSTALL_DOC_Overview=$(usex doc)
		-DINSTALL_SAMPLES=$(usex examples)
		-DINSTALL_TEST_CASES=$(usex test)
	)
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	insinto /etc/env.d/${PN}
	newins "${S}/50${PN}" ${PV}

	if ! use examples; then
		rm -rf "${my_install_dir}"/share/${P}/samples || die
	fi
}

pkg_postinst() {
	eselect ${PN} set ${PV}
	einfo
	elog "After upgrading OpenCASCADE you may have to rebuild packages depending on it."
	elog "You get a list by running \"equery depends sci-libs/opencascade\""
	elog "revdep-rebuild does NOT suffice."
	einfo
}
