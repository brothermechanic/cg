# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils git-r3 eutils

DESCRIPTION="Transform a DICOM volume into a 3d surface mesh"
HOMEPAGE="https://github.com/AOT-AG/DicomToMesh"
EGIT_REPO_URI="https://github.com/AOT-AG/DicomToMesh.git"

LICENSE="UNKNOWN"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

CMAKE_BUILD_TYPE=Release

src_install() {
	dobin ${BUILD_DIR}/${PN}
}

