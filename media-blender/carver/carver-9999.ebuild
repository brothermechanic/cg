# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender addon. Multiple tools to carve or to create objects"
HOMEPAGE="https://blenderartists.org/t/carver-mt-for-2-8/1151461"
EGIT_REPO_URI="https://github.com/clarkx/Carver.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
    insinto /usr/share/blender/addons/
	doins -r "${S}"
}

pkg_postinst() {
	elog
	elog "This blender addon installs to system subdirectory"
	elog "/usr/share/blender/addons/"
	elog "Please, set it to PreferencesFilePaths.scripts_directory"
	elog "More info you can find at page "
	elog "https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path"
	elog
}
