# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg-utils

SLOT="$(ver_cut 1-2)"

DESCRIPTION="Blender is a free and open-source 3D creation suite."
HOMEPAGE="https://www.blender.org/ "
SRC_URI="https://download.blender.org/release/Blender${SLOT}/blender-${PV}-linux-x64.tar.xz"

LICENSE="|| ( GPL-3 BL )"

KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S=${WORKDIR}/blender-4.4.3-linux-x64

QA_PREBUILT="*"

src_install() {
    insinto /opt/blender
    doins -r .
    fperms +x /opt/blender/blender
    fperms +x /opt/blender/blender-launcher
    fperms +x /opt/blender/blender-thumbnailer
    fperms +x /opt/blender/4.4/python/bin/python3.11

    dosym /opt/blender/blender-launcher /usr/bin/blender-bin

    insinto /usr/share/icons/hicolor/256x256/apps
    doicon -s scalable "${S}"/blender.svg
    sed -i -e "s|Exec=blender %f|Exec=blender-bin %f|" blender.desktop || die
    domenu blender.desktop
}

pkg_preinst() {
    echo
    elog "This is a prebuilt binary package of Blender."
    elog "Blender will be installed in /opt/blender/${P}."
    elog "A symlink will be created at /usr/bin/blender."
}

pkg_postinst() {
    xdg_icon_cache_update
    xdg_mimeinfo_database_update
    xdg_desktop_database_update
}

pkg_postrm() {
    xdg_icon_cache_update
    xdg_mimeinfo_database_update
    xdg_desktop_database_update

	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		ewarn
		ewarn "You may want to remove the following directories"
		ewarn "- ~/.config/${PN}/${SLOT}/cache/"
		ewarn "- ~/.cache/cycles/"
		ewarn "It may contain extra render kernels not tracked by portage"
		ewarn
	fi
}

