# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{7,8} )

inherit git-r3 cmake python-single-r1 flag-o-matic

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
EGIT_REPO_URI="https://github.com/PixarAnimationStudios/USD.git"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="alembic -doc +draco embree -imaging openimageio opencolorio -test -tools -hdf5 openvdb osl -ptex +jemalloc +python usdview opengl openexr opensubdiv monolithic"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	openimageio? ( imaging )
	opencolorio? ( imaging )
	opengl? ( imaging )
	opensubdiv? ( imaging )
	ptex? ( imaging )
	openvdb? ( imaging )
	embree? ( imaging )
	usdview? ( python opengl )
	hdf5? ( alembic )
	alembic? ( openexr )
	test? ( python )
"

RDEPEND="
	dev-cpp/tbb
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[python,${PYTHON_MULTI_USEDEP}]
			usdview? (
				dev-python/pyside2[${PYTHON_MULTI_USEDEP}]
				opengl? ( dev-python/pyopengl[${PYTHON_MULTI_USEDEP}] )
			)
		')
	)
	opensubdiv? ( >=media-libs/opensubdiv-3.4.3 )
	opengl? ( >=media-libs/glew-2.0.0 )
	openexr? ( media-libs/openexr )
	openimageio? ( media-libs/openimageio:= )
	opencolorio? ( media-libs/opencolorio )
	osl? ( media-libs/osl )
	ptex? ( media-libs/ptex )
	openvdb? ( media-gfx/openvdb )
	doc? ( app-doc/doxygen[dot] )
	embree? ( media-libs/embree )
	alembic? ( media-gfx/alembic )
	hdf5? (
		media-gfx/alembic[hdf5]
		sci-libs/hdf5[hl]
	)
	draco? ( media-libs/draco )
	jemalloc? ( dev-libs/jemalloc )
"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

CMAKE_BUILD_TYPE=Release

PATCHES=(
	"${FILESDIR}/algorithm.patch"
	"${FILESDIR}/install.diff"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	local mycmakeargs=()
	if use jemalloc; then
		mycmakeargs+=( 
            -DPXR_MALLOC_LIBRARY:path=/usr/lib64/libjemalloc.so
		)
	fi
	mycmakeargs+=(
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_INSTALL_PREFIX=/usr/local
		-DPXR_INSTALL_LOCATION=/usr/share/openusd
		-DPXR_BUILD_ALEMBIC_PLUGIN=$(usex alembic)
		-DPXR_BUILD_DOCUMENTATION=$(usex doc)
		-DPXR_BUILD_DRACO_PLUGIN=$(usex draco)
		-DPXR_BUILD_EMBREE_PLUGIN=$(usex embree)
		-DPXR_BUILD_EXAMPLES=$(usex test)
		-DPXR_BUILD_IMAGING=$(usex imaging)
		-DPXR_BUILD_MATERIALX_PLUGIN=OFF
		-DPXR_BUILD_MONOLITHIC=$(usex monolithic)
		-DPXR_BUILD_OPENCOLORIO_PLUGIN=$(usex opencolorio)
		-DPXR_BUILD_OPENIMAGEIO_PLUGIN=$(usex openimageio)
		-DPXR_BUILD_PRMAN_PLUGIN=OFF
		-DPXR_BUILD_TESTS=$(usex test)
		-DPXR_BUILD_TUTORIALS=$(usex test)
		-DPXR_BUILD_USDVIEW=$(usex usdview)
		-DPXR_BUILD_USD_IMAGING=$(usex imaging)
		-DPXR_BUILD_USD_TOOLS=$(usex tools)
		-DPXR_ENABLE_GL_SUPPORT=$(usex opengl)
		-DPXR_ENABLE_HDF5_SUPPORT=$(usex hdf5)
		-DPXR_ENABLE_OPENVDB_SUPPORT=$(usex openvdb)
		-DPXR_ENABLE_OSL_SUPPORT=$(usex osl)
		-DPXR_ENABLE_PTEX_SUPPORT=$(usex ptex)
		-DPXR_ENABLE_PYTHON_SUPPORT=$(usex python)
		-DPXR_USE_PYTHON_3=$(usex python)
		-DPXR_PYTHON_SHEBANG="${PYTHON}"
		-DPXR_SET_INTERNAL_NAMESPACE=usdBlender
		-DCMAKE_DEBUG_POSTFIX=_d
	)
	cmake_src_configure
}
