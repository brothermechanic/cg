# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon for align the nodes in any nodes editor."
HOMEPAGE="https://github.com/JulienHeijmans/quicksnap"
EGIT_REPO_URI="https://github.com/JulienHeijmans/quicksnap"

LICENSE="MIT"

src_prepare() {
	default
	eapply "${FILESDIR}/quicksnap-no-addon_updater.patch"
	rm -r "${S}"/addon_updater_ops.py
	rm -r "${S}"/addon_updater.py
}
