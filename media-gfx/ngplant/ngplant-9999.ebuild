# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

WX_GTK_VER="3.0"
PYTHON_COMPAT=( python2_7 )

inherit scons-utils multilib toolchain-funcs wxwidgets mercurial python-single-r1

DESCRIPTION="plant modeling software package"
HOMEPAGE="http://ngplant.sourceforge.net"
EHG_REPO_URI="http://hg.code.sf.net/p/ngplant/code"
#EHG_REVISION="v0.9.11"


SLOT="0"
KEYWORDS="~amd64 ~x86"
LICENSE="GPL-3 BSD"
IUSE="doc +examples"

RDEPEND="
	media-libs/glew
	media-libs/freeglut
	x11-libs/wxGTK:3.0
	dev-lang/lua"
DEPEND="${RDEPEND}
	dev-util/scons
	media-libs/freeglut
	virtual/pkgconfig
	dev-libs/libxslt"

pkg_setup() {
	python-single-r1_pkg_setup
}
	
src_prepare() {
	rm -rf extern

	sed \
		-e "s:CC_OPT_FLAGS=.*$:CC_OPT_FLAGS=\'${CFLAGS}\':g" \
		-i SConstruct \
		|| die "failed to correct CFLAGS"

	sed \
		-e "s:LINKFLAGS='-s':LINKFLAGS=\'${LDFLAGS}\':g" \
		-i ngpview/SConscript ${PN}/SConscript devtools/SConscript ngpshot/SConscript \
		|| die "failed to correct LDFLAGS"
}

src_configure() {
        myesconsargs=(
                CC="$(tc-getCC)"
                CXX=$(tc-getCXX)
		LINKFLAGS="${LDFLAGS}"
                LUA_INC="/usr/include/"
		LUA_LIBPATH="/usr/$(get_libdir)/"
		LUA_LIBS="$(pkg-config lua --libs)"
        )
}

src_compile() {
        escons
}

src_install() {
	dobin ${PN}/${PN} ngpview/ngpview devtools/ngpbench ngpshot/ngpshot scripts/ngp2obj.py
	dolib.a ngpcore/libngpcore.a ngput/libngput.a
	insinto /usr/share/${PN}/
	doins -r plugins shaders
	dodoc ReleaseNotes

	if use examples; then
		doins -r samples
	fi

	if use doc; then
		dohtml -r docapi
	fi
	insinto /usr/share/pixmaps/
	doins ngplant/images/ngplant.xpm
	insinto /usr/share/applications/
	doins "${FILESDIR}"/ngplant.desktop
}
