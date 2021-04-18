EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit git-r3 python-single-r1

DESCRIPTION="A central repository of Blender contrib addons"
HOMEPAGE="https://git.blender.org/gitweb/gitweb.cgi/blender-addons-contrib.git"
EGIT_REPO_URI="https://git.blender.org/blender-addons-contrib.git"

if [[ ${PV} == 9999 ]]; then
        EGIT_BRANCH="master"
        KEYWORDS=""
        MY_PV="3.0"
else
    	MY_PV="$(ver_cut 1-2)"
        EGIT_BRANCH="blender-v${MY_PV}-release" 
        KEYWORDS="~amd64 ~x86"
fi
SLOT=${MY_PV}

LICENSE="GPL-2"
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

src_install() {
	egit_clean
	insinto /usr/share/blender/${SLOT}/scripts/${PN}/
	doins -r "${S}"/*
	python_optimize "${ED}/usr/share/blender/${SLOT}/scripts/${PN}/"
}

