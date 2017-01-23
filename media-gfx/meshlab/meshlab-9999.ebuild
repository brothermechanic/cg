# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit qmake-utils git-r3

DESCRIPTION="The open source mesh processing system"
HOMEPAGE="http://www.meshlab.net/"
EGIT_REPO_URI="https://github.com/cnr-isti-vclab/meshlab.git https://github.com/cnr-isti-vclab/vcglib.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
DEPEND="dev-cpp/eigen:3
	dev-cpp/muParser
	dev-qt/qtcore:5
	dev-qt/qtopengl:5
	dev-qt/qtxmlpatterns:5
	media-libs/glew
	media-libs/qhull
	=media-libs/lib3ds-1*
	media-libs/openctm
	sci-libs/levmar
	sys-libs/libunwind
	sci-libs/mpir"
RDEPEND="${DEPEND}"

S="${WORKDIR}/meshlab-9999/src"

src_prepare() {
    cd "${WORKDIR}"
	epatch ${FILESDIR}/*.patch	
    rm -fr meshlab/src/external/{inc,lib}
}

src_configure() {
	eqmake5 -recursive external/external.pro
	eqmake5 -recursive meshlab_full.pro
}

src_compile() {
	cd external && emake
	cd .. && emake
}

src_install() {
	INST_DIR="/opt/Natron"
	exeinto $INST_DIR/bin
	doexe App/Natron
}
