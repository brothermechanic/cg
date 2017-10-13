# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit cmake-multilib

DESCRIPTION="OpenEXR ILM Base libraries"
HOMEPAGE="http://openexr.com/"
# changing sources. Using a revision on the binary in order
# to keep the old one for previous ebuilds.
SRC_URI="https://github.com/openexr/openexr/archive/v${PV}.tar.gz -> openexr-${PV}-r1.tar.gz"

LICENSE="BSD"
SLOT="0/12" # based on SONAME
KEYWORDS=""

DEPEND="virtual/pkgconfig"

MULTILIB_WRAPPED_HEADERS=( /usr/include/OpenEXR/IlmBaseConfig.h )

S="${WORKDIR}/openexr-${PV}/IlmBase"

PATCHES=(
	"${FILESDIR}/${P}-post-release-fixes-v20170109.patch"
	"${FILESDIR}/${P}-use-gnuinstall-dirs.patch"
	"${FILESDIR}/${P}-fix-pkgconfig-file.patch"
)

src_prepare() {
	default
	sed -i -e "s/throw (IEX_NAMESPACE::MathExc)/noexcept (true)/g" Imath/{ImathVec.{h,cpp},ImathMatrix.h} || die
}
