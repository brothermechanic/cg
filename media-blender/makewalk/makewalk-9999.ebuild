EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Mocap retargeting for Blender."
HOMEPAGE="http://www.makehumancommunity.org/wiki/Documentation:MakeWalk"
EGIT_REPO_URI="https://github.com/psemiletov/makewalk"

LICENSE="GPL-2"
RDEPEND="media-makehuman/community-plugins-socket"

