# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3 linux-mod

DESCRIPTION="Linux driver for Realtek PCI-Express card reader chip"
HOMEPAGE="https://github.com/Zibri/Realtek-rts5229-linux-driver"
EGIT_REPO_URI="https://github.com/Zibri/Realtek-rts5229-linux-driver.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

DEPEND="virtual/linux-sources"

MODULE_NAMES="rts5229(misc/drivers/scsi)"
BUILD_TARGETS="default"

src_prepare() {
        default
        sed -e 's/\/lib\/modules\/\$(KVERSION)\/build\//\$(KERNELDIR)/g' \
                -e 's/SUBDIRS/M/g' \
                -i Makefile || die "Sed failed!"
}

pkg_setup() {
        linux-mod_pkg_setup
        BUILD_PARAMS="KERNELDIR=${KERNEL_DIR}"
}

src_compile() {
        # packahe not support parallel make
        MAKEOPTS="-j1"
        linux-mod_src_compile
}
