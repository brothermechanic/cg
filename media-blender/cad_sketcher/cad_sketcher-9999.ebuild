EAPI=8

inherit git-r3

DESCRIPTION="Constraint-based sketcher addon for Blender with support a fully non-destructive workflow"
HOMEPAGE="https://makertales.gumroad.com/l/CADsketcher"
EGIT_REPO_URI="https://github.com/hlorus/CAD_Sketcher"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

RDEPEND="
	dev-python/slvs_py
	media-gfx/blender:=[addons]
"
DEPEND="${RDEPEND}"

RESTRICT="mirror"

src_prepare() {
	default
	if [[ -z ${BLENDER_ADDONS_DIR} ]]; then
		local MY_BV
		for i in "2.93" "3.0" "3.1" "3.2" ; do
			has_version -r media-gfx\/blender\:${i} && MY_BV=${i}
		done
		BLENDER_ADDONS_DIR="/usr/share/blender/${MY_BV}/scripts"
	fi
}

src_install() {
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
