# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils git-r3

DESCRIPTION="the open source system for processing and editing 3D triangular meshes"
HOMEPAGE="http://www.meshlab.net"

GIT_REPO_MESHLAB="https://github.com/cnr-isti-vclab/meshlab.git"
GIT_REPO_VCGLIB="https://github.com/cnr-isti-vclab/vcglib.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="-minimal"
DEPEND="dev-cpp/eigen:3
	dev-cpp/muParser
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtscript:5
	dev-qt/qtxmlpatterns:5
	>=media-gfx/jhead-3.00-r2
	media-libs/glew:0
	media-libs/qhull
	=media-libs/lib3ds-1*
	media-libs/openctm
	sci-libs/levmar
	sci-libs/mpir"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}/src"

PATCHES=(
	"${FILESDIR}"/${PV}-use-external-libs.patch
	"${FILESDIR}"/pluginpath.patch
	"${FILESDIR}"/lapack.patch
#	"${FILESDIR}"/levmar.patch
#	"${FILESDIR}"/meshlabserver_GLU.patch
	"${FILESDIR}"/mpir.patch
#	"${FILESDIR}"/muparser.patch
	"${FILESDIR}"/qt5.11.patch
#	"${FILESDIR}"/rpath.patch
#	"${FILESDIR}"/shaders_dir.patch
)

src_unpack() {
	git-r3_fetch ${GIT_REPO_MESHLAB} refs/heads/master
	git-r3_checkout ${GIT_REPO_MESHLAB} "${WORKDIR}/${PN}"

	git-r3_fetch ${GIT_REPO_VCGLIB} refs/heads/devel
	git-r3_checkout ${GIT_REPO_VCGLIB} "${WORKDIR}/vcglib"
}

src_prepare(){
	default

	rm -r "distrib/plugins/U3D_W32" || die
	rm -r "distrib/plugins/U3D_OSX" || die

#	rm -r "external/muparser_v225" || die "rm failed"

	rm -r "external/glew-2.1.0" || die "rm failed"

	pushd "${WORKDIR}/vcglib" &>/dev/null
#	eapply "${FILESDIR}/lib3ds-vcglib.patch"
	eapply "${FILESDIR}/import_bundle_out.patch"
#	rm -r "eigenlib" || die "rm failed"
	popd &>/dev/null
}

src_configure() {
	eqmake5 -r external/external.pro
	eqmake5 -r meshlab_$(use minimal && echo minimal || echo full).pro
}

src_install() {
	dobin distrib/{meshlab,meshlabserver}
	dolib distrib/libcommon.so.1.0.0
	dosym libcommon.so.1.0.0 /usr/$(get_libdir)/libcommon.so.1
	dosym libcommon.so.1 /usr/$(get_libdir)/libcommon.so
	exeinto /usr/$(get_libdir)/meshlab/plugins
	doexe distrib/plugins/*.so
	insinto /usr/share/meshlab/shaders
	doins -r distrib/shaders/*
	insinto /usr/share/meshlab/plugins
	doins -r distrib/plugins/*
	insinto /usr/share/meshlab/textures
	doins -r distrib/textures/*
	insinto /usr/share/meshlab/sample
	doins -r distrib/sample/*
	newicon "${S}"/meshlab/images/eye512.png "${PN}".png
	make_desktop_entry meshlab "Meshlab" "${PN}" Graphics
}
