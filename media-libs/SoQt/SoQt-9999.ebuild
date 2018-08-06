# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils mercurial

DESCRIPTION="The glue between Coin3D and Qt"
HOMEPAGE="https://bitbucket.org/Coin3D/soqt"

SOQT_REPO_URI="https://bitbucket.org/Coin3D/soqt"
GENERALMSVCGENERATION_REPO_URI="https://bitbucket.org/Coin3D/generalmsvcgeneration"
BOOSTHEADERLIBSFULL_REPO_URI="https://bitbucket.org/Coin3D/boost-header-libs-full"
SOANYDATA_REPO_URI="https://bitbucket.org/Coin3D/soanydata"
SOGUI_REPO_URI="https://bitbucket.org/Coin3D/sogui"

EHG_PROJECT="Coin3D"

LICENSE="|| ( GPL-2 PEL )"
KEYWORDS=""
SLOT="0"
IUSE="+coin-iv-extensions"

RDEPEND="
	>=media-libs/coin-3.1.3
	virtual/opengl
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtopengl:5
	dev-qt/qtwidgets:5
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/${PN}-1.5.0-pkgconfig-partial.patch"
)

DOCS=(AUTHORS ChangeLog FAQ HACKING NEWS README)

src_unpack() {
	EHG_REPO_URI=${GENERALMSVCGENERATION_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/generalmsvcgeneration"
	mercurial_fetch

	EHG_REPO_URI=${BOOSTHEADERLIBSFULL_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/boost-header-libs-full"
	mercurial_fetch

	EHG_REPO_URI=${SOANYDATA_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/soanydata"
	mercurial_fetch

	EHG_REPO_URI=${SOGUI_REPO_URI}
	EHG_CHECKOUT_DIR="${WORKDIR}/sogui"
	mercurial_fetch

	EHG_REPO_URI=${SOQT_REPO_URI}
	EHG_CHECKOUT_DIR="${S}"
	mercurial_fetch
}

src_configure() {
	local myconfargs=(
		-DUSE_QT5=ON
		-DCOIN_IV_EXTENSIONS=$(usex coin-iv-extensions ON OFF)
	)

	cmake-utils_src_configure
}
