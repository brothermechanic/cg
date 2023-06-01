# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon. Screencast Keys Status."
HOMEPAGE="https://github.com/nutti/Screencast-Keys"
EGIT_REPO_URI="https://github.com/nutti/Screencast-Keys"

LICENSE="GPL-3"

ADDON_SOURCE_SUBDIR=${S}/src/screencast_keys
