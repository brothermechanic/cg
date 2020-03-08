# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils git-r3

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
EGIT_REPO_URI="https://github.com/PixarAnimationStudios/USD.git"

LICENSE="Apache-2.0"
SLOT="9999"
KEYWORDS="amd64"

IUSE="cpu_flags_x86_avx examples static-libs test"

RDEPEND="
	dev-libs/boost
	dev-cpp/tbb
"

DOCS=( README.md )

CMAKE_BUILD_TYPE="Release"
