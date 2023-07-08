EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon to import reconstruction results of several libraries"
HOMEPAGE="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"
EGIT_REPO_URI="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"

LICENSE="MIT"

RDEPEND="$(python_gen_cond_dep '
	>=dev-python/pillow-6.0.0[${PYTHON_USEDEP}]
	dev-python/pyntcloud[${PYTHON_USEDEP}]
	dev-python/laspy[${PYTHON_USEDEP}]
')"

PATCHES=(
	"${FILESDIR}"/photogrammetry_importer_fix_FLAT_COLOR.patch
)

ADDON_SOURCE_SUBDIR=${S}/${PN}
