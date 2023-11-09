# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV=$(ver_cut 1-2)

DESCRIPTION="NVIDIA Ray Tracing Engine"
HOMEPAGE="https://developer.nvidia.com/optix"
SRC_URI="NVIDIA-OptiX-SDK-${PV}-linux64-x86_64.sh"
S="${WORKDIR}"

LICENSE="NVIDIA-SDK"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror"
IUSE="doc"

RDEPEND=">=x11-drivers/nvidia-drivers-510"

pkg_nofetch() {
	einfo "Please download ${A} from:"
	einfo "  ${HOMEPAGE}"
	einfo "and move it to your distfiles directory."
}

src_unpack() {
	tail -n +226 "${DISTDIR}"/${A} | tar -zx
	assert "unpacking ${A} failed"
}

src_install() {
	insinto /opt/${PN}
	doins -r include

	DOCS=( doc/OptiX_{API_Reference,Programming_Guide}_${PV}.pdf )
	use doc && einstalldocs
}
