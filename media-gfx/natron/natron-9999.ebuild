# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils git-r3

DESCRIPTION="Node-graph based compositing software"
HOMEPAGE="http://www.natron.fr"
EGIT_REPO_URI="https://github.com/MrKepzie/Natron.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""

IUSE="+openfx-io +openfx-misc +openfx-opencv +openfx-arena +openfx-TuttleOFX"

RDEPEND="dev-qt/qtcore:4
	dev-libs/boost
	dev-libs/expat
	media-libs/glew
	x11-libs/cairo[static-libs]
	dev-python/pyside
	dev-python/shiboken
	dev-cpp/eigen:3
	"
DEPEND="${RDEPEND}"
PDEPEND="media-libs/opencolorio-configs
	openfx-io? ( media-plugins/openfx-io )
	openfx-misc? ( media-plugins/openfx-misc )
	openfx-opencv? ( media-plugins/openfx-opencv )
	openfx-arena? ( media-plugins/openfx-arena )
	openfx-TuttleOFX? ( media-plugins/openfx-TuttleOFX )
	"
src_prepare() {
	cp ${FILESDIR}/config.pri ${S}/
}

src_configure() {
	rm -r ${S}/libs/Eigen3 && sed -e '/Eigen3/d' -i ${S}/libs.pri
	myconf=(
		PREFIX=/usr \
		CONFIG+=custombuild \
		BUILD_USER_NAME=GENTOO \
	)
	eqmake4 ${myconf[@]} -r Project.pro
}
src_install() {
	emake install
	INST_DIR="/opt/Natron"
	exeinto $INST_DIR/bin
	doexe App/Natron
	doexe Renderer/NatronRenderer
	doexe Tests/Tests
	doexe CrashReporter/NatronCrashReporter
	dosym /opt/Natron/bin/Natron /usr/bin/Natron
	dosym /opt/Natron/bin/NatronRenderer /usr/bin/NatronRenderer
	dosym /opt/Natron/bin/Tests /usr/bin/Tests
	dosym /opt/Natron/bin/NatronCrashReporter /usr/bin/NatronCrashReporter
	insinto $INST_DIR/Plugins
	doins -r ${S}/Gui/Resources/PyPlugs
	insinto $INST_DIR/Resources
	doins -r ${S}/Gui/Resources/etc
	
	#don't works in /usr/bin ((( why?
	
	#INSTALL_ROOT=${D} emake install
	#dobin App/Natron
	#dobin Renderer/NatronRenderer
	#dobin Tests/Tests
	#dobin CrashReporter/NatronCrashReporter
	
	insinto /usr/share/pixmaps
	doins ${S}/Gui/Resources/Images/{natronIcon256_linux.png,natronProjectIcon_linux.png}
	insinto /usr/share/mime
	doins ${FILESDIR}/x-natron.xml
	insinto /usr/share/applications
	doins ${FILESDIR}/Natron2.desktop
}