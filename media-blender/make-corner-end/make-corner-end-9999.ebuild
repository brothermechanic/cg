EAPI=7
PYTHON_COMPAT=( python3_{9..10} )
inherit git-r3 python-single-r1

DESCRIPTION="Blender addon for Make Corner and Make End"
HOMEPAGE="https://github.com/Jrome90/Make_Corner_End"
EGIT_REPO_URI="https://github.com/Jrome90/Make_Corner_End.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
	rm -r "${S}"/__pycache__
    insinto ${BLENDER_ADDONS_DIR}/addons/${PN}
	doins -r "${S}"/*
	python_optimize "${ED}/${BLENDER_ADDONS_DIR}/${PN}/"
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
