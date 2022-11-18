EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..5} )

inherit blender-addon

DESCRIPTION="A central repository of Blender addons"
HOMEPAGE="https://git.blender.org/gitweb/gitweb.cgi/blender-addons"
EGIT_REPO_URI="https://git.blender.org/blender-addons"

if [[ ${PV} == 9999 ]]; then
    EGIT_BRANCH="master"
    KEYWORDS=""
    MY_PV="3.5"
else
    MY_PV="$(ver_cut 1-2)"
    EGIT_BRANCH="blender-v${MY_PV}-release"
fi
SLOT=${MY_PV}

LICENSE="GPL-2"

DEPEND="${PYTHON_DEPS}"

PATCHES=(
    "${FILESDIR}/node_wrangler.patch"
)

src_install(){
    : ${GENTOO_BLENDER_ADDONS_DIR:="/usr/share/blender/${SLOT}/scripts"}
    blender-addon_src_install
}
