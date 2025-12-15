# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{0..6} 4_{0..5} 5_0 )

inherit blender-legacy-addon

DESCRIPTION="Blender addon. Modeling/Retopo tools"
HOMEPAGE="https://github.com/mifth/mifthtools"
EGIT_REPO_URI="https://github.com/mifth/mifthtools"
#EGIT_BRANCH="blender_28"
LICENSE="BSD" #BSD-3-Clause

ADDON_SOURCE_SUBDIR="${S}/blender/addons/2.8/mifth_tools"
