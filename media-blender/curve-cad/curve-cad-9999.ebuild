# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_0 )

inherit blender-addon

DESCRIPTION="Blender addon.Bezier Curve CAD Tools for CNC."
HOMEPAGE="https://blenderartists.org/t/bezier-curve-cad-tools-for-cnc-milling-laser-cutting/1100902"
EGIT_REPO_URI="https://github.com/Lichtso/curve_cad"

LICENSE="GPL-3"

