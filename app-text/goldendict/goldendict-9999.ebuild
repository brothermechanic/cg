# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PLOCALES="ar_SA ay_WI be_BY be_BY@latin bg_BG cs_CZ de_DE el_GR es_AR es_BO es_ES fa_IR fr_FR it_IT ja_JP ko_KR lt_LT mk_MK nl_NL pl_PL pt_BR qu_WI ru_RU sk_SK sq_AL sr_SR sv_SE tg_TJ tk_TM tr_TR uk_UA vi_VN zh_CN zh_TW"

inherit qmake-utils git-r3 l10n

DESCRIPTION="Feature-rich dictionary lookup program"
HOMEPAGE="http://goldendict.org/"
EGIT_REPO_URI="https://github.com/goldendict/goldendict.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug qt5"

RDEPEND="
	>=app-text/hunspell-1.2
	dev-libs/eb
	!qt5? (
		dev-qt/qtcore:4[exceptions]
		dev-qt/qtgui:4[exceptions]
		dev-qt/qthelp:4[exceptions]
		dev-qt/qtsingleapplication[qt4]
		dev-qt/qtsvg:4[exceptions]
		dev-qt/qtwebkit:4[exceptions]
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qthelp:5
		dev-qt/qtsingleapplication[qt5]
		dev-qt/qtsvg:5
		dev-qt/qtwebkit:5
		dev-qt/qtx11extras:5
		dev-qt/qtwidgets:5
	)
	media-libs/libao
	media-libs/libogg
	media-libs/libvorbis
	sys-libs/zlib
	x11-libs/libXtst
	media-video/ffmpeg
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
"

src_prepare() {
	if ! use qt5 ; then
		epatch "${FILESDIR}/${PN}-36a761108-qtsingleapplication-unbundle.patch"
	else
		epatch "${FILESDIR}/${PN}-qtsingleapplication-unbundle-qt5.patch"
	fi

	# fix installation path
	sed -i \
		-e '/PREFIX = /s:/usr/local:/usr:' \
		${PN}.pro || die

	# add trailing semicolon
	sed -i -e '/^Categories/s/$/;/' redist/${PN}.desktop || die

	echo "QMAKE_CXXFLAGS_RELEASE = $CFLAGS" >> goldendict.pro
	echo "QMAKE_CFLAGS_RELEASE = $CXXFLAGS" >> goldendict.pro
}

src_configure() {
	if use qt5; then
		eqmake5
	else
		eqmake4
	fi
}

install_locale() {
	insinto /usr/share/apps/${PN}/locale
	doins "${S}"/locale/${1}.qm
	eend $? || dir "failed to install $1 locale"
}

src_install() {
	dobin ${PN}
	domenu redist/${PN}.desktop
	doicon redist/icons/${PN}.png

	# install help files 
	# en by default
	# ru if linguas_ru_RU is set by user
	insinto /usr/share/${PN}/help
	if use linguas_ru_RU ; then
		doins help/gdhelp_ru.qch
	fi
	doins help/gdhelp_en.qch
	
	# install locale files
	# qm files are already in repository, so there's no need to generate them
	l10n_for_each_locale_do install_locale	
}
