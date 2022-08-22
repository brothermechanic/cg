EAPI=6

inherit git-r3 eutils blender-addons-dir

DESCRIPTION="Blender addon for computational design"
HOMEPAGE="http://www.co-de-it.com/wordpress/code/blender-tissue"
EGIT_REPO_URI="https://github.com/alessandro-zomparelli/tissue.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]
        dev-python/numba"

src_install() {
	egit_clean
    insinto ${GENTOO_BLENDER_ADDONS_DIR}/addons/${PN}
	doins -r "${S}"/*
}

pkg_postinst() {
	elog
	elog "This blender addon installs to system subdirectory"
	elog "${GENTOO_BLENDER_ADDONS_DIR}"
	elog "You can set it to make.conf before"
	elog "Please, set it to PreferencesFilePaths.scripts_directory"
	elog "More info you can find at page "
	elog "https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path"
	elog
}
