EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..1} )

inherit blender-addon

DESCRIPTION="Blender addon to import reconstruction results of several libraries"
HOMEPAGE="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"
EGIT_REPO_URI="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"

LICENSE="MIT"

RDEPEND="$(python_gen_cond_dep '
	>=dev-python/pillow-6.0.0[${PYTHON_USEDEP}]
	dev-python/pyntcloud[${PYTHON_USEDEP}]
	dev-python/laspy[${PYTHON_USEDEP}]
	dev-python/lazrs[${PYTHON_USEDEP}]
')"

ADDON_SOURCE_SUBDIR=${S}/${PN}

src_prepare() {
    default
    # Fix blender 3.4+ gpu shader color name
    has_version -b '>=media-gfx/blender-3.4.0' && sed -re 's/\(\"[2-3]D_([A-Z]+_COLOR)\"\)/\(\"\1\"\)/g' -i photogrammetry_importer/opengl/draw_manager.py
}
