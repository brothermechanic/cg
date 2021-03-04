EAPI=7

inherit git-r3 eutils

DESCRIPTION="Blender addon for image pasting from system clipboard"
HOMEPAGE="https://gumroad.com/l/BmQWu"
EGIT_REPO_URI="https://github.com/Yeetus3141/ImagePaste"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
		media-gfx/blender[addons]
		>=dev-python/pillow-6.0.0[xcb]
"

PATCHES=(
	${FILESDIR}/remove_pillow_dep.patch
)

src_prepare() {
	default
	local MY_PV=$(has_version -r "media-gfx/blender:2.93[addons]" && echo 2.93 || echo 2.92)
	if [[ -z ${BLENDER_ADDONS_DIR} ]]; then
		BLENDER_ADDONS_DIR="/usr/share/blender/${MY_PV}/scripts"
	fi
}

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
