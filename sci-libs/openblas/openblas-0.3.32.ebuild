# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED="blas lapack"
FORTRAN_STANDARD=95

inherit cmake flag-o-matic fortran-2 toolchain-funcs

MY_P=OpenBLAS-${PV}
DESCRIPTION="Optimized BLAS library based on GotoBLAS2"
HOMEPAGE="https://github.com/OpenMathLib/OpenBLAS"
SRC_URI="https://github.com/OpenMathLib/OpenBLAS/releases/download/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}"/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ppc ppc64 ~riscv x86 ~x64-macos"
IUSE="+blas +cblas cpudetection clapack debug deprecated eselect-ldso index64 +lapack +lapacke openmp pthread relapack static-libs test"
REQUIRED_USE="
	?? ( openmp pthread )
	relapack? ( lapack )
	lapacke? ( lapack )
"
RESTRICT="!cpudetection? ( bindist ) !test? ( test )"

RDEPEND="
	eselect-ldso? (
		>=app-eselect/eselect-blas-0.2
		>=app-eselect/eselect-lapack-0.2
	)
"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-0.3.32-shared-blas-lapack.patch"
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	elog "This software has a massive number of options that"
	elog "are configurable and it is *impossible* for all of"
	elog "those to fit inside any manageable ebuild."
	elog "The Gentoo provided package has enough to build"
	elog "a fully optimized library for your targeted CPU."
	elog "You can set the CPU target using the environment"
	elog "variable - OPENBLAS_TARGET or it will be detected"
	elog "automatically from the target toolchain (supports"
	elog "cross compilation toolchains)."
	elog "You can control the maximum number of threads"
	elog "using OPENBLAS_NTHREAD, default=64 and number of "
	elog "parallel calls to allow before further calls wait"
	elog "using OPENBLAS_NPARALLEL, default=8."
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	if use lapack || use blas; then fortran-2_pkg_setup; fi
}

src_prepare() {
	cmake_src_prepare

	# TODO: Unbundle lapack like Fedora does?
	# https://src.fedoraproject.org/rpms/openblas/blob/rawhide/f/openblas-0.2.15-system_lapack.patch

	# Don't build the tests as part of "make all". We'll do
	# it explicitly later if the test phase is enabled.
	sed -i -e "/^all :: tests/s: tests::g" Makefile || die

	# If 64bit-index is needed, create second library with LIBPREFIX=libopenblas64
	if use index64; then
		cp -aL "${S}" "${S}-index64" || die
	fi
}

src_configure() {
	# List of most configurable options is in Makefile.rule.

	# Not an easy fix, https://github.com/xianyi/OpenBLAS/issues/4128
	filter-lto

	append-fflags $(test-flags-FC -fallow-argument-mismatch)
	append-fflags $(test-flags-FC -Wno-error=unused-command-line-argument-hard-error-in-future)

	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_C_COMPILER="$(tc-getCC)"
		-DCMAKE_CXX_COMPILER="$(tc-getCXX)"
		-DCMAKE_Fortran_COMPILER="$(tc-getFC)"
		-DCMAKE_C_FLAGS="${CFLAGS}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}"
		-DCMAKE_Fortran_FLAGS="${FFLAGS}"
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DBUILD_WITHOUT_LAPACKE=$(usex !lapacke)
		-DBUILD_WITHOUT_LAPACK=$(usex !lapack)
		-DBUILD_WITHOUT_CBLAS=$(usex !cblas)
		-DBUILD_LAPACK_DEPRECATED=$(usex deprecated)
		-DBUILD_TESTING=$(usex test)
		-DC_LAPACK=$(usex clapack)
		-DDYNAMIC_ARCH=$(usex cpudetection)
		-DBUILD_RELAPACK=$(usex relapack)
		-DLAPACK_STRLEN=$(tc-get-ptr-size)
		-DINTERFACE64=$(usex index64)
		-DLIBNAMESUFFIX=$(usex index64 64 "")
		-DUSE_OPENMP=$(usex openmp)
	)

	# Needs to be here, otherwise gets overriden by cmake.eclass
	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release) cmake_src_configure
}

src_install() {
	cmake_src_install
}

pkg_postinst() {
	use eselect-ldso || return
	local libdir=$(get_libdir) me="openblas"

	# check blas
	eselect blas add ${libdir} "${EROOT}"/usr/${libdir}/blas/${me} ${me}
	local current_blas=$(eselect blas show ${libdir} | cut -d' ' -f2)
	if [[ ${current_blas} == "${me}" || -z ${current_blas} ]]; then
		eselect blas set ${libdir} ${me}
		elog "Current eselect: BLAS/CBLAS ($libdir) -> [${current_blas}]."
	else
		elog "Current eselect: BLAS/CBLAS ($libdir) -> [${current_blas}]."
		elog "To use blas [${me}] implementation, you have to issue (as root):"
		elog "\t eselect blas set ${libdir} ${me}"
	fi

	# check lapack
	eselect lapack add ${libdir} "${EROOT}"/usr/${libdir}/lapack/${me} ${me}
	local current_lapack=$(eselect lapack show ${libdir} | cut -d' ' -f2)
	if [[ ${current_lapack} == "${me}" || -z ${current_lapack} ]]; then
		eselect lapack set ${libdir} ${me}
		elog "Current eselect: LAPACK ($libdir) -> [${current_lapack}]."
	else
		elog "Current eselect: LAPACK ($libdir) -> [${current_lapack}]."
		elog "To use lapack [${me}] implementation, you have to issue (as root):"
		elog "\t eselect lapack set ${libdir} ${me}"
	fi
}

pkg_postrm() {
	if use eselect-ldso; then
		eselect blas validate
		eselect lapack validate
	fi
}
