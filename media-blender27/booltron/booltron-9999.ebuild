# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit git-r3 eutils

DESCRIPTION="Blender addon. A super fast booleans"
HOMEPAGE="https://github.com/mrachinskiy/blender-addon-booltron"
EGIT_REPO_URI="https://github.com/mrachinskiy/blender-addon-booltron.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="media-gfx/blender27[addons]"

src_install() {
	egit_clean
	if VER="/usr/share/blender/2.79";then
		insinto ${VER}/scripts/addons/
		diropts -g users -m0775
		doins -r "${S}"
	fi
}

pkg_postrm() {
	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		rm -r ${ROOT}usr/share/blender/2.79/scripts/addons/"${P}"
	fi
}
