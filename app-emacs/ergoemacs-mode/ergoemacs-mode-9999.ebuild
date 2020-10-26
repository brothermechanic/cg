# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit elisp git-r3

DESCRIPTION="Ergoemacs Keybindings for Emacs"
HOMEPAGE="http://ergoemacs.github.io/"
EGIT_REPO_URI="https://github.com/ergoemacs/ergoemacs-mode.git"

KEYWORDS="amd64 x86"
LICENSE="GPL-3"
SLOT="0"

DEPEND="${RDEPEND}"

SITEFILE="50${PN}-gentoo.el"

