# Copyright 1999-2019 Gentoo Foundation

EAPI=6

inherit eutils java-pkg-opt-2 flag-o-matic

DESCRIPTION="Proj.4 cartographic projection software"
HOMEPAGE="http://trac.osgeo.org/proj/"
SRC_URI="
	http://download.osgeo.org/proj/${P}.tar.gz
	http://download.osgeo.org/proj/${PN}-datumgrid-1.8.zip
"
#	http://trac.osgeo.org/proj/export/2647/trunk/proj/src/org_proj4_PJ.h -> ${P}-org_proj4_PJ.h

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ia64 ppc ppc64 ~s390 ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="java static-libs"

RDEPEND=""
DEPEND="
	app-arch/unzip
	java? ( >=virtual/jdk-1.5 )"

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"/data || die
	mv README README.NAD || die
#	cp "${DISTDIR}/${P}-org_proj4_PJ.h" "${S}/src/org_proj4_PJ.h" || die
	unpack ${PN}-datumgrid-1.8.zip
}

src_configure() {
	if use java; then
		export JAVACFLAGS="$(java-pkg_javac-args)"
		append-cflags "$(java-pkg_get-jni-cflags)"
	fi
	econf \
		$(use_enable static-libs static) \
		$(use_with java jni)
}

src_install() {
	default
	dodoc data/README.NAD
	insinto /usr/share/proj
	insopts -m 755
	doins test/cli/test27 test/cli/test83
	insopts -m 644
	doins test/cli/pj_out27.dist test/cli/pj_out83.dist
	prune_libtool_files
}
