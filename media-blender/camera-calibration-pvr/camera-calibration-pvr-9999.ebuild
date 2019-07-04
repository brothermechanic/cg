# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_7 ) 
inherit git-r3 distutils-r1 

DESCRIPTION="Blender addon. Camera Calibration using Perspective Views of Rectangles"
HOMEPAGE="https://blenderartists.org/forum/showthread.php?414359-Add-on-Camera-Calibration-using-Perspective-Views-of-Rectangles"
EGIT_REPO_URI="https://github.com/mrossini-ethz/camera-calibration-pvr.git"
EGIT_BRANCH="blender-2.8"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender[addons]
        dev-python/setuptools[${PYTHON_USEDEP}]
        dev-python/pycairo[${PYTHON_USEDEP}]"

src_compile() { 
   cd "${S}"/figures
   python generate-figures.py
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
