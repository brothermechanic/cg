# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit git-2 eutils

DESCRIPTION="CAD from a parallel universe"
HOMEPAGE="http://www.mattkeeter.com/projects/antimony/3/"
EGIT_REPO_URI="https://github.com/mkeeter/antimony.git"

LICENSE="MIT"

SLOT="0"

KEYWORDS="~x86 ~amd64"

IUSE=""

DEPEND="
	>dev-util/lemon-3.8.11
	sys-devel/flex
	dev-lang/python:3.4
	dev-libs/boost[python]
	media-libs/libpng
	dev-qt/qtcore:5
	"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/gentoo.patch
	epatch_user
}


src_configure() {
	/usr/lib64/qt5/bin/qmake PREFIX="{D}/usr/" sb.pro
}

src_install() {
	dobin app/antimony
	insinto /usr/bin
	doins -r app/sb
	newicon "${FILESDIR}"/antimony.png "${PN}".png
	make_desktop_entry antimony "Antimony"
}
