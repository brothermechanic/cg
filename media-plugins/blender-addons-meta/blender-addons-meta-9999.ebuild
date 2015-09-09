# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

DESCRIPTION="Blender addons meta package"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="
	=media-gfx/blender-9999
	media-plugins/blender-blam
	media-plugins/blender-booltron
	media-plugins/blender-export-selected
	media-plugins/blender-kinoraw-tools
	media-plugins/blender-light-studio
	media-plugins/blender-mira-tools
	media-plugins/blender-push-pull-face
	media-plugins/blender-uvsquares
	media-plugins/blender-vsfmbundle
	"