# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v3
# $Header: $
EAPI=5

PYTHON_COMPAT=( python3_5 )
PYTHON_REQ_USE="sqlite"

inherit python-r1 ${scm_eclass}

DESCRIPTION="Baidu Pan client for Linux Desktop users"
HOMEPAGE="https://github.com/LiuLang/bcloud"
SRC_URI="https://www.dropbox.com/s/bkbihy3gp5vseau/bcloud-3.8.2.2.rus.tar.gz"
LICENSE="GPL-3"
SLOT="0"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
KEYWORDS="~amd64 ~x86"
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
	x11-libs/gtk+-3.20.8:3[introspection]
	"
S="${WORKDIR}/bcloud-3.8.2.1"
src_install() {
	python_foreach_impl python_domodule ${PN}
	dobin bcloud-gui
	insinto usr
	doins -r share
}
