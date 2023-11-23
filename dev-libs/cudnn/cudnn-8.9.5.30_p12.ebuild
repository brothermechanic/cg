# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit unpacker

BASE_V="$(ver_cut 0-3)"
CUDA_V="$(ver_cut 4-)"
CUDA_V="${CUDA_V##*p}"

DESCRIPTION="NVIDIA Accelerated Deep Learning on GPU library"
HOMEPAGE="https://developer.nvidia.com/cudnn"
SRC_URI="
	amd64? ( cudnn-linux-x86_64-${PV%%_*}_cuda${CUDA_V}-archive.tar.xz )
	ppc64? ( cudnn-linux-ppc64le-${PV%%_*}_cuda${CUDA_V}-archive.tar.xz )
	arm64? ( cudnn-linux-sbsa-${PV%%_*}_cuda${CUDA_V}-archive.tar.xz )
"

LICENSE="NVIDIA-cuDNN"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64 ~ppc64 ~arm64"
RESTRICT="mirror fetch"

RDEPEND="=dev-util/nvidia-cuda-toolkit-${CUDA_V}*"

QA_PREBUILT="
	/opt/cuda/targets/x86_64-linux/lib/*
	/opt/cuda/targets/ppc64le-linux/lib/*
	/opt/cuda/targets/sbsa-linux/lib/*
"

S="${WORKDIR}/cudnn-linux-x86_64-${PV%%_*}_cuda${CUDA_V}-archive"

pkg_nofetch() {
	einfo "Please download ${A} from https://developer.nvidia.com/rdp/cudnn-archive"
	einfo "The archive should then be placed into your DISTDIR directory."
}

src_install() {
	use amd64 && insinto /opt/cuda/targets/x86_64-linux
	use ppc64 && insinto /opt/cuda/targets/ppc64le-linux
	use arm64 && insinto /opt/cuda/targets/sbsa-linux

	doins -r include lib
}
