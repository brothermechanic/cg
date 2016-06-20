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
		-DBoost_INCLUDE_DIRS=/usr/include/boost/
		-DBoost_FOUND=ON
		-DBOOST_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_LIB_USES_BOOST=ON
		-DALEMBIC_BOOST_FOUND=ON
		-DALEMBIC_BOOST_INCLUDE_PATH=/usr/include/boost/
		-DALEMBIC_BOOST_LIBRARIES=boost_python-${EPYTHON#python}
		-DALEMBIC_PYTHON_ROOT=/usr/lib64
		-DALEMBIC_HDF5_LIBS="-lhdf5_hl -lhdf5_cpp -lhdf5_fortran -lhdf5"
		-DILMBASE_ROOT=/usr
		-DILMBASE_VERSION=2.2
		-DILMBASE_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DALEMBIC_ILMBASE_LIBRARIES="-lhdf5_hl -lhdf5_cpp -lhdf5_fortran -lhdf5"
		-DOPENEXR_INCLUDE_PATHS=/usr/include/OpenEXR
		-DALEMBIC_PYILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DALEMBIC_PYILMBASE_LIBRARIES="-lPyIex -lPyImath"
		-DUSE_PRMAN=OFF
		-DUSE_ARNOLD=OFF
		-DUSE_MAYA=OFF
		-DALEMBIC_SHARED_LIBS=ON
		-DUSE_TESTS=OFF
		-DUSE_STATIC_BOOST=OFF
		-DUSE_STATIC_HDF5=OFF
		-DUSE_PYALEMBIC=ON
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
