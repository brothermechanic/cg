EAPI=7

inherit git-r3

DESCRIPTION="Blender addon. Mocap retargeting for Blender."
HOMEPAGE="http://www.makehumancommunity.org/wiki/Documentation:MakeWalk"
EGIT_REPO_URI="https://github.com/psemiletov/makewalk.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]
        media-makehuman/community-plugins-socket"

src_install() {
	egit_clean
    insinto ${BLENDER_ADDONS_DIR}/addons/${PN}
	doins -r "${S}"/*
}

pkg_postinst() {
	elog
	elog "This blender addon installs to system subdirectory"
	elog "${BLENDER_ADDONS_DIR}"
	elog "You can set it to make.conf before"
	elog "Please, set it to PreferencesFilePaths.scripts_directory"
	elog "More info you can find at page "
	elog "https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path"
	elog
}
