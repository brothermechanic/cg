# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python3_6 )

inherit cmake-utils flag-o-matic python-single-r1 git-r3

DESCRIPTION="An open framework for storing and sharing 3D geometry data."
HOMEPAGE="http://alembic.io"
EGIT_REPO_URI="https://github.com/alembic/alembic.git"

LICENSE="ALEMBIC"
SLOT="0"
KEYWORDS=""
IUSE="doc"
RDEPEND=""
DEPEND="${PYTHON_DEPS}
	>=dev-util/cmake-2.8
	>=dev-libs/boost-1.44[${PYTHON_USEDEP}]
	=media-libs/openexr-2.2*
	>=media-libs/ilmbase-1.0.1
	media-libs/pyilmbase[${PYTHON_USEDEP}]
	doc? ( >=app-doc/doxygen-1.7.3 )"

CMAKE_BUILD_TYPE=Release
	
src_prepare() {
	append-cxxflags -std=c++11
	rm -Rf build || die
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DUSE_HDF5=OFF
		-DUSE_MAYA=OFF
		-DUSE_BINARIES=OFF
		-DALEMBIC_SHARED_LIBS=OFF
		-DALEMBIC_LIB_USES_BOOST=ON
		-DILMBASE_ROOT=/usr
		-DILMBASE_VERSION=2.2
	)
	cmake-utils_src_configure
}
