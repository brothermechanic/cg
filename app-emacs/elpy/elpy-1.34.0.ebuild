# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6..9} )

inherit elisp distutils-r1

DESCRIPTION="A helper library for integrating Python development in Emacs"
HOMEPAGE="http://github.com/jorgenschaefer/elpy"
SRC_URI="https://github.com/jorgenschaefer/elpy/archive/${PV}.tar.gz -> ${P}.tar.gz"

KEYWORDS="amd64 x86"
LICENSE="GPL-3"
SLOT="0"

DEPEND="${RDEPEND}
dev-python/coverage
dev-python/jedi
dev-python/mock
dev-python/virtualenv
dev-python/nose"

ELISP_REMOVE="${PN}-pkg.el"

src_compile() {
	elisp_src_compile
}

src_install() {
	elisp_src_install
}
