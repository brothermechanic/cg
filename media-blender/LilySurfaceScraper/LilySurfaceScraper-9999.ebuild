# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Import material from a single URL"
HOMEPAGE="https://github.com/eliemichel/LilySurfaceScraper"
EGIT_REPO_URI="https://github.com/eliemichel/LilySurfaceScraper"

LICENSE="GPL-3"

src_prepare() {
	default
	rm -r "${S}"/blender/LilySurfaceScraper/site-packages
}
