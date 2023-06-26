# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit git-r3 cmake python-single-r1 flag-o-matic

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
EGIT_REPO_URI="https://github.com/PixarAnimationStudios/USD.git"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64"
IUSE="alembic -doc +draco embree -imaging openimageio opencolorio -test -tools -hdf5 openvdb osl -ptex +jemalloc python usdview opengl openexr opensubdiv monolithic"

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
			dev-libs/boost:=[python,${PYTHON_USEDEP}]
			usdview? (
				dev-python/pyside2[${PYTHON_USEDEP}]
				dev-python/pyside2-tools[tools,${PYTHON_USEDEP}]
				opengl? ( dev-python/pyopengl[${PYTHON_USEDEP}] )
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
	#"${FILESDIR}/fix-size_t-in-singularTask.h.patch"
)

USD_PATH="/opt/${PN}"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_configure() {
	if use draco; then
		append-cppflags -DDRACO_ATTRIBUTE_VALUES_DEDUPLICATION_SUPPORTED=ON
		append-cppflags -DDRACO_ATTRIBUTE_INDICES_DEDUPLICATION_SUPPORTED=ON
		append-cppflags -DTBB_SUPPRESS_DEPRECATED_MESSAGES=1
	fi

	mycmakeargs+=(
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}${USD_PATH}"
		-DPXR_INSTALL_LOCATION="${EPREFIX}${USD_PATH}"
		-DPXR_BUILD_ALEMBIC_PLUGIN=$(usex alembic ON OFF)
		-DPXR_BUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DPXR_BUILD_DRACO_PLUGIN=$(usex draco ON OFF)
		-DPXR_BUILD_EMBREE_PLUGIN=$(usex embree ON OFF)
		-DPXR_BUILD_EXAMPLES=$(usex test ON OFF)
		-DPXR_BUILD_IMAGING=$(usex imaging ON OFF)
		-DPXR_BUILD_MATERIALX_PLUGIN=OFF
		-DPXR_BUILD_MONOLITHIC=$(usex monolithic ON OFF)
		-DPXR_BUILD_OPENCOLORIO_PLUGIN=$(usex opencolorio ON OFF)
		-DPXR_BUILD_OPENIMAGEIO_PLUGIN=$(usex openimageio ON OFF)
		-DPXR_BUILD_PRMAN_PLUGIN=OFF
		-DPXR_BUILD_TESTS=$(usex test ON OFF)
		-DPXR_BUILD_TUTORIALS=$(usex test ON OFF)
		-DPXR_BUILD_USDVIEW=$(usex usdview ON OFF)
		-DPXR_BUILD_USD_IMAGING=$(usex imaging ON OFF)
		-DPXR_BUILD_USD_TOOLS=$(usex tools ON OFF)
		-DPXR_ENABLE_GL_SUPPORT=$(usex opengl ON OFF)
		-DPXR_ENABLE_HDF5_SUPPORT=$(usex hdf5 ON OFF)
		-DPXR_ENABLE_OPENVDB_SUPPORT=$(usex openvdb ON OFF)
		-DPXR_ENABLE_OSL_SUPPORT=$(usex osl ON OFF)
		-DPXR_ENABLE_PTEX_SUPPORT=$(usex ptex ON OFF)
		-DPXR_ENABLE_PYTHON_SUPPORT=$(usex python ON OFF)
		-DPXR_USE_PYTHON_3=ON
		-DPXR_PYTHON_SHEBANG="${PYTHON}"
		-DPXR_SET_INTERNAL_NAMESPACE="usdBlender"
#		-DCMAKE_DEBUG_POSTFIX=_d
#		-DPXR_MALLOC_LIBRARY="${EPREFIX}/usr/lib64/libjemalloc.so
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install

	use usdview && dosym ${USD_PATH}/bin/usdview /usr/bin/usdview
	dosym "${USD_PATH}"/include/pxr /usr/include/pxr

	echo "${USD_PATH}"/lib >> 99-${PN}.conf
	insinto /etc/ld.so.conf.d/
	doins 99-${PN}.conf

	chrpath --delete "${D}$${USD_PATH}/lib/*.so"
}

