# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-r3

DESCRIPTION="Color Configurations for OpenColorIO"
HOMEPAGE="http://opencolorio.org/"
EGIT_REPO_URI="https://github.com/MrKepzie/OpenColorIO-Configs.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="media-libs/opencolorio"
DEPEND="${RDEPEND}"

src_install() {
	insinto /usr/share/OpenColorIO-Configs
	doins -r "${S}"/*
}
