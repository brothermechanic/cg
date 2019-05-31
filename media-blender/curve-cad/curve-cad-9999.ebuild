# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

SCRIPTS="/usr/share/blender/scripts"

inherit git-r3 eutils

DESCRIPTION="Blender addon.Bezier Curve CAD Tools for CNC."
HOMEPAGE="https://blenderartists.org/t/bezier-curve-cad-tools-for-cnc-milling-laser-cutting/1100902"
EGIT_REPO_URI="https://github.com/Lichtso/curve_cad.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]"

src_install() {
	egit_clean
    insinto ${SCRIPTS}/addons/${PN}
	doins -r "${S}"/*.py
}

pkg_postinst() {
	elog
	elog "This blender addon installs to system subdirectory"
	elog "${SCRIPTS}"
	elog "Please, set it to PreferencesFilePaths.scripts_directory"
	elog "More info you can find at page "
	elog "https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path"
	elog
}
