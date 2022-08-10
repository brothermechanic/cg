EAPI=8

inherit git-r3

DESCRIPTION="Blender addon to import reconstruction results of several libraries"
HOMEPAGE="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"
EGIT_REPO_URI="https://github.com/SBCV/Blender-Addon-Photogrammetry-Importer"

LICENSE="MIT"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

DEPEND=""
RDEPEND="
	media-gfx/blender:=[addons]
	>=dev-python/pillow-6.0.0
	dev-python/pylas
	dev-python/pyntcloud
"

RESTRICT="mirror"

#PATCHES=(
#	${FILESDIR}/
#)

src_prepare() {
	default
	if [[ -z ${BLENDER_ADDONS_DIR} ]]; then
		local MY_BV
		for i in "2.93" "3.2" "3.3" "3.4" ; do
			has_version -r media-gfx\/blender\:${i} && MY_BV=${i}
		done
		BLENDER_ADDONS_DIR="/usr/share/blender/${MY_BV}/scripts"
	fi
}

src_install() {
	insinto ${BLENDER_ADDONS_DIR}/addons
	doins -r "${S}"/photogrammetry_importer
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
