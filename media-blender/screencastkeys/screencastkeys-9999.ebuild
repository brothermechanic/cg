# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6


inherit git-r3 eutils

DESCRIPTION="Blender addon. Screencast Keys Status."
HOMEPAGE="https://github.com/nutti/Screencast-Keys"
EGIT_REPO_URI="https://github.com/nutti/Screencast-Keys.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
    insinto ${BLENDER_ADDONS_DIR}/addons/
	doins -r "${S}"/src/${PN}
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
