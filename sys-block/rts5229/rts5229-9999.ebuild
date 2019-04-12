# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit linux-mod git-r3

DESCRIPTION="Linux driver for Realtek PCI-Express card reader chip"
HOMEPAGE="https://github.com/Zibri/Realtek-rts5229-linux-driver"
EGIT_REPO_URI="https://github.com/Zibri/Realtek-rts5229-linux-driver.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

MODULE_NAMES="rts5229(misc/drivers/scsi)"
BUILD_TARGETS="default"

pkg_setup() {
	linux-mod_pkg_setup
	BUILD_PARAMS="KERNELDIR=${KERNEL_DIR}"
}
