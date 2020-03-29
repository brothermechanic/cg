# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{7,8} )

inherit distutils-r1 git-r3 vcs-clean

DESCRIPTION="Blender addon. Node based visual scripting system designed for motion graphics in Blender."
HOMEPAGE="https://github.com/JacquesLucke/animation_nodes"
EGIT_REPO_URI="https://github.com/JacquesLucke/animation_nodes.git"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]
        dev-python/numpy"

src_install() {
    egit_clean
	echo "{\"Copy Target\" : \"${D}${BLENDER_ADDONS_DIR}/addons\"}" > conf.json
    insinto ${BLENDER_ADDONS_DIR}/addons
	esetup.py build --copy --noversioncheck
	python_optimize "${D%/}${BLENDER_ADDONS_DIR%/}/addons/animation_nodes"
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
