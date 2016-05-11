# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/AwesomeBump/AwesomeBump-9999.ebuild,v 1.1 2015-03-27 13:19:13 brothermechanic Exp $

#TODO create menu launcher

EAPI=5

inherit git-2 eutils qmake-utils

DESCRIPTION="A free, open source, cross-platform video editor"
HOMEPAGE="http://awesomebump.besaba.com/"
EGIT_REPO_URI="https://github.com/kmkolasinski/AwesomeBump.git"

LICENSE="GPL-3"

SLOT="0"

KEYWORDS=""

IUSE="gl330"

DEPEND="
        dev-qt/qtcore:5
        dev-qt/qtopengl:5
        dev-qt/qtscript:5[scripttools]
        virtual/opengl
        "

RDEPEND="${DEPEND}"

#S="${WORKDIR}/Sources"

src_unpack(){
        git-2_src_unpack
        unset EGIT_BRANCH EGIT_COMMIT
        EGIT_SOURCEDIR="${S}/Sources/utils/QtnProperty" \
        EGIT_REPO_URI="https://github.com/lexxmark/QtnProperty.git" \
        git-2_src_unpack
}

src_prepare() {
        local config
        cd Sources/utils/QtnProperty
        eqmake5 -r
        cd $S
        if use gl330 ; then
                config+="release_gl330"
        fi
        eqmake5 CONFIG+=${config}
}

src_compile() {
        cd Sources/utils/QtnProperty
        emake || die
        cd $S
        emake || die
}

src_install() {

        INST_DIR="/opt/AwesomeBump"
        insinto $INST_DIR
        doins -r Bin/*
        exeinto $INST_DIR
        local executable
        if use gl330; then
                executable='AwesomeBumpGL330'
        else
                executable='AwesomeBump'
        fi 
        find "${S}/workdir" -name ${executable} -exec doexe '{}' +
        sed -e 's!\./AwesomeBump!\./AwesomeBumpGL330!g' "${FILESDIR}/AwesomeBump.sh" > $"${S}/AwesomeBump.sh"
        dobin "${S}/AwesomeBump.sh"
        newicon Sources/resources/icons/icon.png "${PN}".png || die
        make_desktop_entry AwesomeBump.sh
}
