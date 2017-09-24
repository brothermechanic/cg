# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v3
# $Header: $
EAPI=5

PYTHON_COMPAT=( python3_6 )
PYTHON_REQ_USE="sqlite"

inherit python-r1 git-r3

EGIT_REPO_URI="https://github.com/Yufeikang/bcloud.git"
EGIT_COMMIT="v3.9.1"

DESCRIPTION="Baidu Pan client for Linux Desktop users"
HOMEPAGE="https://github.com/LiuLang/bcloud"

LICENSE="GPL-3"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

IUSE+="gnome-keyring"

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	dev-python/lxml[${PYTHON_USEDEP}]
	dev-python/cssselect[${PYTHON_USEDEP}]
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/keyring[${PYTHON_USEDEP}]
	dev-python/pycrypto[${PYTHON_USEDEP}]
	dev-python/pyinotify[${PYTHON_USEDEP}]
	x11-themes/gnome-icon-theme-symbolic
	x11-libs/libnotify
	gnome-keyring? ( gnome-base/libgnome-keyring  )
	"

src_install() {
	python_foreach_impl python_domodule ${PN}
	dobin bcloud-gui
	insinto usr
	doins -r share
}
