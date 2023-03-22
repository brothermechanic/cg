EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} )

inherit blender-addon

DESCRIPTION="Blender addon to import reconstruction results of several libraries"
HOMEPAGE="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"
EGIT_REPO_URI="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"

LICENSE="MIT"

RDEPEND="
	>=dev-python/pillow-6.0.0
	dev-python/pylas
	dev-python/pyntcloud
"

#S="${WORKDIR}/${P}/${PN}"
