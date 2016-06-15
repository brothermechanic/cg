# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python3_5 )

inherit cmake-utils eutils python-single-r1

DESCRIPTION="An open framework for storing and sharing 3D geometry data."
HOMEPAGE="http://alembic.io"
SRC_URI="https://github.com/alembic/alembic/archive/1.6.tar.gz -> ${P}.tar.gz"

LICENSE="ALEMBIC"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"
RDEPEND=""
DEPEND="${PYTHON_DEPS}
	>=dev-util/cmake-2.8
	>=dev-libs/boost-1.61[${PYTHON_USEDEP}]
	>=media-libs/ilmbase-2.2.0
	>=sci-libs/hdf5-1.8.17
	>=media-libs/pyilmbase-2.2.0[${PYTHON_USEDEP}]
	doc? ( >=app-doc/doxygen-1.7.3 )"

S="${WORKDIR}"/${PN}-1.6

CMAKE_BUILD_TYPE=Release

src_prepare() {
	sed -e "s:/usr/lib64/.*/config:/usr/lib64:g;s:/usr/lib/.*/config:/usr/lib:g" \
		-i python/PyAlembic/CMakeLists.txt || die
	sed -e "/build.*.cmake/d;s/ALEMBIC_NO_BOOTSTRAP FALSE/ALEMBIC_NO_BOOTSTRAP TRUE/;s:/alembic-\${VERSION}::g" \
		-i CMakeLists.txt || die

#	epatch "${FILESDIR}"/unique_ptr.patch

	rm -Rf build || die
}

src_configure() {
	local mycmakeargs=(
		-DLIBPYTHON_VERSION=${EPYTHON#python}m
		-DBoost_PYTHON_LIBRARY=boost_python-${EPYTHON#python}
		-DBoost_INCLUDE_DIRS=/usr/include/boost
		-DBoost_FOUND=ON
		-DBOOST_LIBRARY_DIR=/usr/lib64
		-DALEMBIC_SHARED_LIBS=ON
		-DALEMBIC_LIB_USES_BOOST=ON
		-DALEMBIC_BOOST_FOUND=ON
		-DALEMBIC_BOOST_INCLUDE_PATH=/usr/include/boost
		-DALEMBIC_BOOST_LIBRARIES=boost_python-${EPYTHON#python}
		-DALEMBIC_PYTHON_ROOT=/usr/lib64
		-DILMBASE_ROOT=/usr
		-DILMBASE_VERSION=2.2
		-DPYILMBASE_ROOT=/usr
		-DUSE_PRMAN=OFF
		-DUSE_ARNOLD=OFF
		-DUSE_MAYA=OFF
		-DUSE_TESTS=OFF
		-DUSE_STATIC_BOOST=ON
		-DUSE_STATIC_HDF5=ON
		-DUSE_PYALEMBIC=OFF
	)
	cmake-utils_src_configure

#		-DALEMBIC_HDF5_LIBS="-lhdf5_hl -lhdf5_cpp -lhdf5_fortran -lhdf5"
#		-DILMBASE_LIBRARY_DIR=/usr/lib64
#		-DALEMBIC_ILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
#		-DALEMBIC_ILMBASE_LIBS="-lIex -lIexMath -lIlmThread -lImath -lHalf"
#		-DALEMBIC_ILMBASE_IMATH_LIB=Imath
#		-DALEMBIC_ILMBASE_ILMTHREAD_LIB=IlmThread
#		-DALEMBIC_ILMBASE_IEX_LIB=Iex
#		-DALEMBIC_ILMBASE_IEXMATH_LIB=IexMath
#		-DALEMBIC_ILMBASE_HALF_LIB=Half
#		-DOPENEXR_INCLUDE_PATHS=/usr/include/OpenEXR
#		-DALEMBIC_OPENEXR_LIBRARIES="-lIlmImfUtil -lIlmImf"
#		-DALEMBIC_PYILMBASE_INCLUDE_DIRECTORY=/usr/include/OpenEXR
#		-DALEMBIC_PYILMBASE_LIBRARIES="-lPyIex -lPyImath"
#		-DALEMBIC_PYILMBASE_PYIMATH_MODULE=/usr/lib64/python3.5/site-packages/imathmodule.so

}

src_compile() {
	cmake-utils_src_compile
}

src_install() {
	cmake-utils_src_install
}
