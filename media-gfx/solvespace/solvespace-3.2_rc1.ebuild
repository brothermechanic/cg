# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_OPTIONAL=1
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517=scikit-build-core
PYTHON_COMPAT=( python3_{11..13} )
# solvespace's libdxfrw is quite heavily modified and incompatible with
# the upstream libdxfrw.
DXFRW_COMMIT="0b7b7b709d9299565db603f878214656ef5e9ddf"
DXFRW_PV="0.6.3"
DXFRW_P="libdxfrw-${DXFRW_PV}-${DXFRW_COMMIT}"

# dynamically linking with mimalloc causes segfaults when changing
# language. bug #852839
MIMALLOC_COMMIT="f819dbb4e4813fab464aee16770f39f11476bfea"
MIMALLOC_PV="2.0.6"
MIMALLOC_P="mimalloc-${MIMALLOC_PV}-${MIMALLOC_COMMIT}"

MY_PV="${PV/_rc/-rc}"

inherit cmake distutils-r1 toolchain-funcs xdg

DESCRIPTION="Parametric 2d/3d CAD"
HOMEPAGE="https://solvespace.com"
SRC_URI="https://github.com/solvespace/solvespace/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://github.com/solvespace/libdxfrw/archive/${DXFRW_COMMIT}.tar.gz -> ${DXFRW_P}.tar.gz
	!system-mimalloc? ( https://github.com/microsoft/mimalloc/archive/${MIMALLOC_COMMIT}.tar.gz -> ${MIMALLOC_P}.tar.gz )"

# licenses
# + SolveSpace (GPL-3+)
# |- Bitstream Vera (BitstreamVera)
# + libdxfrw (GPL-2+)
# + mimalloc (MIT)

LICENSE="BitstreamVera GPL-2+ GPL-3+ !system-mimalloc? ( MIT )"
SLOT="0"
KEYWORDS="amd64 ~arm64 ~x86"
IUSE="gui +lto openmp +python +system-mimalloc"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
"
DEPEND="
	gui? (
		dev-cpp/atkmm:0
		dev-cpp/glibmm:2
		dev-cpp/gtkmm:3.0[X]
		dev-cpp/pangomm:1.4
		dev-libs/libspnav[X]
		dev-libs/libsigc++:2
		sys-libs/zlib
		media-libs/fontconfig
		media-libs/freetype:2[X]
		media-libs/libpng:0=
		virtual/opengl
		x11-libs/cairo[X]
		x11-libs/gtk+:3[X]
	)
	dev-cpp/eigen:3
	dev-libs/glib:2
	dev-libs/json-c:=
	system-mimalloc? ( dev-libs/mimalloc:= )
"
BDEPEND="
	python? (
		${DISTUTILS_DEPS}
		${PYTHON_DEPS}
		test? ( $(python_gen_cond_dep 'dev-python/pyyaml[${PYTHON_USEDEP}]') )
	)
	virtual/pkgconfig
"

S="${WORKDIR}"/${P/_rc/-rc}

RESTRICT="mirror
!test? ( test )"

distutils_enable_tests pytest

# This is shown to the user in the UI and --version and should be
# updated during each version bump.
MY_HASH="70bde63cb32a7f049fa56cbdf924e2695fcb2916"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	rm -r extlib/libdxfrw || die
	mv "${WORKDIR}"/libdxfrw-${DXFRW_COMMIT} extlib/libdxfrw || die

	if use system-mimalloc; then
		# Ideally this patch would be applied unconditionally and it
		# would add an option like `-DUSE_SYSTEM_MIMALLOC=On', but
		# hopefully this patch is only needed temporarily and the odd
		# interactions with the system's libmimalloc will be fixed
		# shortly... :)
		PATCHES=( "${FILESDIR}"/${PN}-3.2-use-system-mimalloc.patch )
	else
		rm -r extlib/mimalloc || die
		mv "${WORKDIR}"/mimalloc-${MIMALLOC_COMMIT} extlib/mimalloc || die
	fi

	sed -i '/include(GetGitCommitHash)/d' CMakeLists.txt || die

	cmake_src_prepare
	use python && distutils-r1_src_prepare
}

src_configure() {
	if use python; then
		sed -e "s/\(cmake.build-type = \"\).\+\"/\1Release\"/" \
			-e "s/\(ENABLE_LTO = \"\).\+\"/\1$(usex lto)\"/" \
			-e "s/\(FORCE_VENDORED_Eigen3 = \"\).\+\"/\1OFF\"/" \
			-e "s/\(ENABLE_OPENMP = \"\).\+\"/\1$(usex openmp)\"/" \
			-e "s/\(ENABLE_TESTS = \"\).\+\"/\1$(usex test)\"/" -i pyproject.toml

		sed -e "/ENABLE_PYTHON_LIB = \"ON\"/a CMAKE_POLICY_VERSION_MINIMUM=3.5\n\
CMAKE_INSTALL_LIBDIR = \"$(python_get_sitedir)\"" -i pyproject.toml
	fi

	local mycmakeargs=(
		-DCMAKE_POLICY_VERSION_MINIMUM=3.5
		-DCMAKE_SKIP_RPATH=ON
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DENABLE_OPENMP=$(usex openmp)
		-DENABLE_GUI=$(usex gui)
		-DGIT_COMMIT_HASH=${MY_HASH}
		-DENABLE_PYTHON_LIB=$(usex python)
		-DENABLE_LTO=$(usex lto)
		-DENABLE_TESTS=$(usex test)
	)

	CMAKE_BUILD_TYPE="Release" cmake_src_configure
}

src_compile() {
	cmake_src_compile
	use python && distutils-r1_src_compile
}

src_test() {
	local -x LD_LIBRARY_PATH="${BUILD_DIR}"
	cmake_src_test
	use python && distutils-r1_src_test
}

src_install() {
	cmake_src_install
	use python && {
		distutils-r1_src_install
		rm -rfv ${D}/usr/slvs || die "Removing duplicates failed."
	}
}
