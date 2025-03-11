# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..4} )

inherit blender-addon

DESCRIPTION="Blender addon. Sverchok is a powerful parametric tool for architects"
HOMEPAGE="http://nikitron.cc.ua/sverchok_en.html"
EGIT_REPO_URI="https://github.com/nortikin/sverchok"
EGIT_BRANCH="master"

LICENSE="GPL-3"
IUSE="freecad"

RDEPEND="$(python_gen_cond_dep '
	dev-python/numpy[${PYTHON_USEDEP}]
    dev-python/cython[${PYTHON_USEDEP}]
    dev-python/scipy[${PYTHON_USEDEP}]
    dev-python/geomdl[${PYTHON_USEDEP}]
    dev-python/PyMCubes[${PYTHON_USEDEP}]
    freecad? ( media-gfx/freecad[${PYTHON_SINGLE_USEDEP}] )
')"

src_prepare() {
    eapply_user
    eapply "${FILESDIR}/approx_subd_to_nurbs.patch"
    # set icons by default
    sed -i '/name="Show icons in Shift-A menu",/{n;s/.*/\t\default=True,/}' settings.py
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/[2,3]D_([A-Z]+_COLOR)/\1/g' -i node_scripts/SNLite_templates/bpy_stuff/bgl_3dview_drawing.py \
        nodes/viz/*.py nodes/solid/solid_viewer.py utils/sv_batch_primitives.py old_nodes/vd_draw_experimental.py || die "Sed failed"
}

src_install() {
    if use freecad ; then
        insinto $(python_get_sitedir)/
        echo "/usr/lib64/freecad/lib64/" > ${D}/$(python_get_sitedir)/freecad_path.pth || die
    fi
    blender-addon_src_install
}
