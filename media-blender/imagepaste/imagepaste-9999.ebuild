EAPI=7

inherit git-r3 eutils

DESCRIPTION="Blender addon for image pasting from system clipboard"
HOMEPAGE="https://gumroad.com/l/BmQWu"
EGIT_REPO_URI="https://github.com/Yeetus3141/ImagePaste"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
IUSE=""
SLOT="0"

DEPEND=""
RDEPEND="
	media-gfx/blender:=[addons]
"

RESTRICT="mirror"

PATCHES=(
	${FILESDIR}/unbundle_bin.patch
)

src_prepare() {
	default
	rm -r "${S}"/imagepaste/clipboard/linux/bin/xclip
	if [[ -z ${BLENDER_ADDONS_DIR} ]]; then
		local MY_BV
		for i in "2.93" "3.0" ; do
			MY_BV="$( has_version -r media-gfx\/blender\:${i} && echo ${i} )"
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
