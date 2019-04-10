# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_7 )

inherit distutils-r1

DESCRIPTION="Coin3D bindings for Python"
HOMEPAGE="https://pivy.coin3d.org/"
SRC_URI="https://github.com/FreeCAD/pivy/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	>=media-libs/coin-4.0.0a_pre20180416:=
	>=media-libs/SoQt-1.6.0a_pre20180813:=
"
DEPEND="
	${RDEPEND}
	dev-lang/swig
"

src_prepare() {
	default

	# Those fake headers are not provided
	touch "${S}"/fake_headers/{cstddef,cstdarg,cassert} || die "Failed to touch fake headers"
}
