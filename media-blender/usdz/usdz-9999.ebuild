EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. UDSZ file import/export add-on"
HOMEPAGE="https://github.com/robmcrosby/BlenderUSDZ"
EGIT_REPO_URI="https://github.com/robmcrosby/BlenderUSDZ"

LICENSE="GPL-3"

ADDON_SOURCE_SUBDIR=${S}/io_scene_usdz

