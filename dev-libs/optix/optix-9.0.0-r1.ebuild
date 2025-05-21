# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="NVIDIA Ray Tracing Engine"
HOMEPAGE="https://developer.nvidia.com/rtx/ray-tracing/optix"
SRC_URI="
	https://github.com/NVIDIA/optix-dev/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
"

#NVIDIA-OptiX-SDK-${PV}-linux64-x86_64.sh
S="${WORKDIR}/${PN}-dev-${PV}"

LICENSE="NVIDIA-SDK-v2017.06.13 BSD"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror test"
IUSE="doc"

RDEPEND=">=x11-drivers/nvidia-drivers-560"

pkg_nofetch() {
	einfo "Please download ${A} from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move it to your distfiles directory."
}

#src_unpack() {
#	tail -n +226 "${DISTDIR}"/${A} | tar -zx
#	assert "unpacking ${A} failed"
#}

src_install() {
	insinto "/opt/${PN}"

	doins -r include/

	use doc && dodoc README.md
}
