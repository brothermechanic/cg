# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-1.5.8-r2.ebuild,v 10 2015/05/15 00:00:00 perestoronin Exp $

EAPI=5
PYTHON_COMPAT=( python3_5 )

inherit cmake-utils eutils python-single-r1 git-r3

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
	>=media-libs/ilmbase-1.0.1
	>=sci-libs/hdf5-1.8.7
	media-libs/pyilmbase[${PYTHON_USEDEP}]
	doc? ( >=app-doc/doxygen-1.7.3 )"

CMAKE_BUILD_TYPE=Release
	
src_prepare() {
	append-cxxflags -std=c++11
	sed -e "s:/usr/lib64/.*/config:/usr/lib64:g;s:/usr/lib/.*/config:/usr/lib:g" \
		-i python/{PyAlembic,PyAbcOpenGL}/CMakeLists.txt || die
	sed -e "/build.*.cmake/d;s/ALEMBIC_NO_BOOTSTRAP FALSE/ALEMBIC_NO_BOOTSTRAP TRUE/;s:/alembic-\${VERSION}::g" \
		-i CMakeLists.txt || die
	sed -e "s:ALEMBIC_SHARED_LIBS AND DARWIN:ALEMBIC_SHARED_LIBS:g" \
		-i lib/Alembic/CMakeLists.txt || die

	epatch "${FILESDIR}"/hdf5_v110.patch

	rm -Rf build || die
}

src_configure() {
	local mycmakeargs=(
		-DLIBPYTHON_VERSION=${EPYTHON#python}m
		-DBoost_PYTHON_LIBRARY=boost_python-${EPYTHON#python}
		-DBOOST_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_BOOST_INCLUDE_PATH=/usr/include/boost/
		-DALEMBIC_BOOST_LIBRARIES=boost_python-${EPYTHON#python} boost_program_options boost_thread
		-DALEMBIC_PYTHON_ROOT=/usr/lib64
		-DILMBASE_ROOT=/usr
		-DILMBASE_VERSION=2.2
		-DILMBASE_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DOPENEXR_INCLUDE_PATHS=/usr/include/OpenEXR
		-DALEMBIC_PYILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DUSE_PRMAN=OFF
		-DUSE_ARNOLD=OFF
		-DUSE_MAYA=OFF
		-DALEMBIC_SHARED_LIBS=OFF
		-DUSE_TESTS=OFF
		-DUSE_STATIC_BOOST=ON
		-DUSE_STATIC_HDF5=ON
		-DUSE_PYALEMBIC=OFF
		-DUSE_HDF5=ON
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
