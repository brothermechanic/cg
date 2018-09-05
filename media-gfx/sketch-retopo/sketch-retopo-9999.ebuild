# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils git-r3

DESCRIPTION="Sketch-Based Mesh Generator"
HOMEPAGE="http://igl.ethz.ch/projects/sketch-retopo"
EGIT_REPO_URI="https://github.com/eapenzhan/sketch-retopo.git"

LICENSE="SketchRetopo"
SLOT="0"
KEYWORDS=""
IUSE=""

#DEPEND="dev-cpp/eigen"

#RDEPEND="${DEPEND}"

#src_prepare() {
#    rm -r src/Eigen
#	find -type f -name \*.hh -exec sed -i -r 's/<Eigen\//<eigen3\/Eigen\//g' {} \;
#	find -type f -name \*.cc -exec sed -i -r 's/<Eigen\//<eigen3\/Eigen\//g' {} \;
#	cmake-utils_src_prepare
#}

src_install() {
	dobin ${BUILD_DIR}/{SketchRetopo,patchgen_demo}
	make_desktop_entry SketchRetopo "Mesh Generator"
}
