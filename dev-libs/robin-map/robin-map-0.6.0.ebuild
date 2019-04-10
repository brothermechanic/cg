# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="C++ implementation of a fast hash map and hash set using robin hood hashing"
HOMEPAGE="https://github.com/Tessil/robin-map"
SRC_URI="https://github.com/Tessil/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE=""

DEPEND=""
