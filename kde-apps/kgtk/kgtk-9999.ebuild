# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit git-r3 cmake-utils


DESCRIPTION="KGtk allow Gtk applications to use Kdialogs."
HOMEPAGE="https://github.com/sandsmark/kgtk"
EGIT_REPO_URI="https://github.com/sandsmark/kgtk.git"

LICENSE="GPL-2"

SLOT="0"

KEYWORDS=""

IUSE=""

DEPEND="kde-apps/kdialog"
RDEPEND="${DEPEND}"

src_configure() {
	local mycmakeargs
	mycmakeargs+=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DLIB_SUFFIX=64
		-DNOTHREADS=OFF
	)
	cmake-utils_src_configure
}

