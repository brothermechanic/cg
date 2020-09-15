EAPI=7

PYTHON_COMPAT=( python3_{6..9} )
inherit git-r3

DESCRIPTION="A central repository of Blender contrib addons"
HOMEPAGE="https://git.blender.org/gitweb/gitweb.cgi/blender-addons-contrib.git"
EGIT_REPO_URI="https://git.blender.org/blender-addons-contrib.git"

LICENSE="GPL-2"
SLOT="2.91"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="${DEPEND}"

src_install() {
	egit_clean
    insinto /usr/share/blender/${SLOT}/scripts/${PN}/
	doins -r "${S}"/*
}

