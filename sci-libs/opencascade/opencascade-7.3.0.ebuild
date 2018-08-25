# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit check-reqs cmake-utils eapi7-ver eutils flag-o-matic java-pkg-opt-2 multilib

DESCRIPTION="Development platform for CAD/CAE, 3D surface/solid modeling and data exchange"
HOMEPAGE="http://www.opencascade.com/"
# convert version string x.x.x to x_x_x
MY_PV="$(ver_rs 1- '_')"
SRC_URI="https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=refs/tags/V${MY_PV};sf=tgz -> ${P}.tar.gz"

LICENSE="|| ( Open-CASCADE-LGPL-2.1-Exception-1.0 LGPL-2.1 )"
SLOT="${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="debug doc examples ffmpeg freeimage gl2ps gles2 java tbb test +vtk"

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
	ffmpeg? ( virtual/ffmpeg )
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
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_CONFIGURATION_TYPES="Gentoo"
		-DUSE_D3D=no
		-DUSE_FFMPEG=$(usex ffmpeg)
		-DUSE_FREEIMAGE=$(usex freeimage)
		-DUSE_GL2PS=$(usex gl2ps)
		-DUSE_GLES2=$(usex gles2)
		-DUSE_TBB=$(usex tbb)
		-DUSE_VTK=$(usex vtk)
		-DBUILD_WITH_DEBUG=$(usex debug)
		-DBUILD_DOC_Overview=$(usex doc)
		-DINSTALL_DOC_Overview=$(usex doc)
		-DINSTALL_SAMPLES=$(usex examples)
		-DINSTALL_TEST_CASES=$(usex test)
		-DCMAKE_INSTALL_PREFIX="/usr/$(get_libdir)/${P}/ros"
		-DINSTALL_DIR_DOC="/usr/share/doc/${P}"
		-DINSTALL_DIR_CMAKE="/usr/$(get_libdir)/cmake"
	)

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# make draw.sh non-world-writable
	chmod go-w "${D}/${EROOT}/usr/$(get_libdir)/${P}/ros/bin/draw.sh"

	# /etc/env.d
	sed -e "s|VAR_CASROOT|${EROOT}usr/$(get_libdir)/${P}/ros|g" < "${FILESDIR}/50${PN}" > "${S}/50${PN}"
	doenvd "${S}/50${PN}"

	# /etc/ld.so.conf.d
	dodir /etc/ld.so.conf.d/
	echo "${EROOT}usr/$(get_libdir)/${P}/ros/lib" > ${ED}/etc/ld.so.conf.d/50${PN}.conf || die

	# remove examples
	if ! use examples; then
		rm -rf "${EROOT}/usr/$(get_libdir)/${P}/ros/share/${P}/samples" || die
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
