# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alembic/alembic-1.5.8-r2.ebuild,v 10 2015/05/15 00:00:00 perestoronin Exp $

EAPI=5
PYTHON_COMPAT=( python3_5 )

inherit cmake-utils eutils python-single-r1

DESCRIPTION="An open framework for storing and sharing 3D geometry data."
HOMEPAGE="http://alembic.io"
SRC_URI="https://github.com/alembic/alembic/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RDEPEND=""
DEPEND="${PYTHON_DEPS}
	>=dev-util/cmake-2.8
	>=dev-libs/boost-1.44[${PYTHON_USEDEP}]
	>=media-libs/ilmbase-1.0.1
	>=sci-libs/hdf5-1.8.17
	media-libs/pyilmbase[${PYTHON_USEDEP}]
	doc? ( >=app-doc/doxygen-1.7.3 )"

CMAKE_BUILD_TYPE=Release
	
src_prepare() {
	sed -e "s:/usr/lib64/.*/config:/usr/lib64:g;s:/usr/lib/.*/config:/usr/lib:g" \
		-i python/{PyAlembic,PyAbcOpenGL}/CMakeLists.txt || die
	sed -e "/build.*.cmake/d;s/ALEMBIC_NO_BOOTSTRAP FALSE/ALEMBIC_NO_BOOTSTRAP TRUE/;s:/alembic-\${VERSION}::g" \
		-i CMakeLists.txt || die

	rm -Rf build || die
}

src_configure() {
	local mycmakeargs=(
		-DLIBPYTHON_VERSION=${EPYTHON#python}m
		-DBoost_PYTHON_LIBRARY=boost_python-${EPYTHON#python}
		-DBoost_INCLUDE_DIRS=/usr/include/boost/
		-DBoost_FOUND=ON
		-DBOOST_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_BOOST_FOUND=ON
		-DALEMBIC_BOOST_INCLUDE_PATH=/usr/include/boost/
		-DALEMBIC_BOOST_LIBRARIES=boost_python-${EPYTHON#python}
		-DALEMBIC_PYTHON_ROOT=/usr/lib64
		-DILMBASE_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
		-DALEMBIC_ILMBASE_IEX_LIB=Iex
		-DALEMBIC_ILMBASE_IEXMATH_LIB=IexMath
		-DALEMBIC_ILMBASE_HALF_LIB=Half
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
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
