# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_{0..1} 5_1 )

inherit blender-legacy-addon

DESCRIPTION="A suite of retopology tools."
HOMEPAGE="https://docs.retopoflow.com"
EGIT_REPO_URI="https://github.com/CGCookie/retopoflow"
#EGIT_OVERRIDE_REPO_GIT_GITHUB_COM_CGCOOKIE_ADDON_COMMON="https://github.com/CGCookie/addon_common"
#EGIT_OVERRIDE_BRANCH_GIT_GITHUB_COM_CGCOOKIE_ADDON_COMMON="less_recursion"
#EGIT_OVERRIDE_COMMIT_GIT_GITHUB_COM_CGCOOKIE_ADDON_COMMON=""
EGIT_SUBMODULES=()
if [[ ${PV} == *9999* ]]; then
	EGIT_BRANCH="v4.0.1"
else
	EGIT_BRANCH="v${PV}"
fi

LICENSE="GPL-3"

