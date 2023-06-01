EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon for computational design"
HOMEPAGE="http://www.co-de-it.com/wordpress/code/blender-tissue"
EGIT_REPO_URI="https://github.com/alessandro-zomparelli/tissue"

LICENSE="GPL-3"

RDEPEND="dev-python/numba"

