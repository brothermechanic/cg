# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Sverchok is a powerful parametric tool for architects"
HOMEPAGE="http://nikitron.cc.ua/sverchok_en.html"
EGIT_REPO_URI="https://github.com/nortikin/sverchok"
EGIT_BRANCH="master"

LICENSE="GPL-3"
IUSE="freecad"

RDEPEND="
        dev-python/numpy
        dev-python/cython
        dev-python/scipy
        dev-python/geomdl
        dev-python/PyMCubes
        freecad? ( media-gfx/freecad )
        "

src_prepare() {
    eapply_user
    eapply "${FILESDIR}/approx_subd_to_nurbs.patch"
    # set icons by default
    sed -i '/name="Show icons in Shift-A menu",/{n;s/.*/\t\default=True,/}' settings.py

}

src_install() {
    if use freecad ; then
        insinto $(python_get_sitedir)/
        echo "/usr/lib64/freecad/lib64/" > ${D}/$(python_get_sitedir)/freecad_path.pth || die
    fi
    blender-addon_src_install
}
