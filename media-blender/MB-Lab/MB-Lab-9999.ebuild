EAPI=7

inherit git-r3 eutils blender-addons-dir

DESCRIPTION="Blender addon. Character creation tool"
HOMEPAGE="https://mblab.dev/"
EGIT_REPO_URI="https://github.com/animate1978/MB-Lab.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
    insinto ${GENTOO_BLENDER_ADDONS_DIR}/addons/
    diropts -g users -m0775
	doins -r "${S}"
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

pkg_postrm() {
	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		rm -r ${ROOT}${GENTOO_BLENDER_ADDONS_DIR}/addons/${P}
	fi
}
