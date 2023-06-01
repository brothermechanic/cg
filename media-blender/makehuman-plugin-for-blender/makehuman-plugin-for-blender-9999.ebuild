EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Sync operations with MakeHuman"
HOMEPAGE="https://github.com/makehumancommunity/makehuman-plugin-for-blender"
EGIT_REPO_URI="https://github.com/makehumancommunity/makehuman-plugin-for-blender"

LICENSE="GPL-2"

ADDON_SOURCE_SUBDIR="${S}/blender_source/MH_Community"
