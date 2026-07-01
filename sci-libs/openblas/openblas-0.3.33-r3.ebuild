# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

FORTRAN_NEEDED="fortran"
FORTRAN_STANDARD=95

inherit flag-o-matic fortran-2 toolchain-funcs

MY_P=OpenBLAS-${PV}
DESCRIPTION="Optimized BLAS library based on GotoBLAS2"
HOMEPAGE="https://github.com/OpenMathLib/OpenBLAS"
SRC_URI="https://github.com/OpenMathLib/OpenBLAS/releases/download/v${PV}/${MY_P}.tar.gz"
S="${WORKDIR}"/${MY_P}

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc ppc64 ~riscv ~x86 ~x64-macos"
IUSE="+cblas cpudetection debug deprecated eselect-ldso fortran index64 lapack +lapacke openmp pthread relapack static-libs test"
REQUIRED_USE="
	?? ( openmp pthread )
	lapack? ( fortran )
	deprecated? ( lapack )
	lapacke? ( lapack )
	relapack? ( lapack )
"
RESTRICT="!cpudetection? ( bindist ) !test? ( test )"

RDEPEND="
	eselect-ldso? (
		>=app-eselect/eselect-blas-0.2
		lapack? ( >=app-eselect/eselect-lapack-0.2 )
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

	use fortran && fortran-2_pkg_setup
}

src_prepare() {
	default

	# Don't build the tests as part of "make all". We'll do
	# it explicitly later if the test phase is enabled.
	sed -e "/^all \:\: tests/s: tests::g" \
		-e "/^SUBDIRS_ALL \= /s: test .* cpp_thread_test::" \
		-e "/^.PHONY \: all/s: test ctest::" \
		-i Makefile || die

	# If 64bit-index is needed, create second library with LIBPREFIX=libopenblas64
	if use index64; then
		cp -aL "${S}" "${S}-index64" || die
	fi
}

src_configure() {
	# List of most configurable options is in Makefile.rule.

	# Not an easy fix, https://github.com/xianyi/OpenBLAS/issues/4128
	filter-lto

	tc-export CC FC LD AR AS RANLIB

	append-fflags "-I${ESYSROOT}/usr/include"

	# Bypasses the f2c duplicate symbol errors (like second_ and dsecnd_)
	append-ldflags "-Wl,--allow-multiple-definition"

	# Fixes linker crashing on unmatched f2c external symbol suffixes
	append-ldflags "-Wl,--undefined-version"

	# Instruct compiler to tolerate old implicit f2c signatures
	append-cflags "-Wno-error=incompatible-pointer-types"

	# HOSTCC is used for scripting
	export HOSTCC="$(tc-getBUILD_CC)"

	# Threading options
	export USE_THREAD=0
	export USE_OPENMP=0
	if use openmp; then
		USE_THREAD=1
		USE_OPENMP=1
	elif use pthread; then
		USE_THREAD=1
		USE_OPENMP=0
	fi

	# Disable submake with -j and default optimization flags in Makefile.system
	# Makefile.rule says to not modify COMMON_OPT/FCOMMON_OPT...
	export MAKE_NB_JOBS=-1 COMMON_OPT=" " FCOMMON_OPT=" "

	# Target CPU ARCH options generally detected automatically from cross toolchain
	if use cpudetection ; then
		export DYNAMIC_ARCH=1 NO_AFFINITY=1 TARGET=GENERIC
	fi

	case $(tc-get-ptr-size) in
		4)
			# NUM_BUFFERS = MAX(50, (2*NUM_PARALLEL*NUM_THREADS)
			# BUFFER_SIZE = (16 << 20) (on x86)
			# NUM_BUFFERS * BUFFER_SIZE is allocated and must be
			# <4GiB on 32-bit arches (bug #967251).
			#
			# Scale down to 2*8*(16 << 20) = 256MiB for 32-bit
			# arches. This avoids spinning in blas_memory_alloc
			# which doesn't handle ENOMEM.
			export NUM_PARALLEL=${OPENBLAS_NPARALLEL:-2}
			export NUM_THREADS=${OPENBLAS_NTHREAD:-8}
			;;
		8)
			# XXX: The current values here rely on overcommit
			# for most systems (bug #967026).
			export NUM_PARALLEL=${OPENBLAS_NPARALLEL:-8}
			export NUM_THREADS=${OPENBLAS_NTHREAD:-64}
			;;
		*)
			die "Unexpected tc-get-ptr-size. Please file a bug."
			;;
	esac

	# Allow setting OPENBLAS_TARGET to override auto detection in case the
	# toolchain is not enough to detect.
	# https://github.com/xianyi/OpenBLAS/blob/develop/TargetList.txt
	if ! use cpudetection ; then
		if [[ -n "${OPENBLAS_TARGET}" ]] ; then
			export TARGET="${OPENBLAS_TARGET}"
		elif [[ ${CBUILD} != ${CHOST} ]] ; then
			case ${CHOST} in
				aarch64-*)
					export TARGET="ARMV8"
					export BINARY="64"
				;;
				powerpc64le-*)
					export TARGET="POWER8"
					export BUILD_BFLOAT16=1
					export BINARY=64
				;;
			esac
		fi
	fi

	export NO_STATIC=$(usex !static-libs 1 0)
	export NO_SHARED=0
	export NO_LAPACKE=$(usex !lapacke 1 0)
	export NO_LAPACK=$(usex !lapack 1 0)
	export NO_FBLAS=$(usex !lapack 1 0)
	export C_LAPACK=$(usex lapacke 1 0)
	export ONLY_CBLAS=$(usex !fortran 1 0)
	export BUILD_LAPACK_DEPRECATED=$(usex deprecated 1 0)
	export BUILD_RELAPACK=$(usex relapack 1 0)
	export PREFIX="${EPREFIX}/usr"
}

myemake64() {
	emake -C "${S}-index64" \
		INTERFACE64=1 \
		LIBNAMESUFFIX=64 \
		"${@}"
}

src_compile() {
	emake shared
	if use index64; then
		emake64 shared
	fi

	if use eselect-ldso; then
		emake -C interface shared-blas
		use lapack && emake -C interface shared-lapack
		use cblas && emake -C interface shared-cblas
		use lapacke && emake -C interface shared-lapacke
	fi
}

src_test() {
	emake tests
	if use index64; then
		emake64 tests
	fi
}

src_install() {
	local libdir=$(get_libdir) me="${PN}"
	emake install \
		DESTDIR="${D}" \
		OPENBLAS_INCLUDE_DIR='$(PREFIX)'/include/${me} \
		OPENBLAS_LIBRARY_DIR='$(PREFIX)'/${libdir}

	dodoc GotoBLAS_*.txt *.md Changelog.txt

	if use index64; then
		emake64 install \
			DESTDIR="${D}" \
			OPENBLAS_INCLUDE_DIR='$(PREFIX)'/include/${me}64 \
			OPENBLAS_LIBRARY_DIR='$(PREFIX)'/${libdir}
	fi

	use eselect-ldso || return
	# BLAS
	exeinto "/usr/${libdir}/blas/${me}"
	doexe "interface/libblas.so.3"
	dosym "libblas.so.3" "/usr/${libdir}/blas/${me}/libblas.so"

	if use cblas; then
		exeinto "/usr/${libdir}/blas/${me}"
		doexe "interface/libcblas.so.3"
		dosym "libcblas.so.3" "/usr/${libdir}/blas/${me}/libcblas.so"
	fi

	if use lapack; then
		exeinto "/usr/${libdir}/lapack/${me}"
		doexe "interface/liblapack.so.3"
		dosym "liblapack.so.3" "/usr/${libdir}/lapack/${me}/liblapack.so"
	fi

	if use lapacke; then
		exeinto "/usr/${libdir}/lapack/${me}"
		doexe "interface/liblapacke.so.3"
		dosym "liblapacke.so.3" "/usr/${libdir}/lapack/${me}/liblapacke.so"
	fi
}

pkg_postinst() {
	use eselect-ldso || return
	local libdir=$(get_libdir) me="openblas"

	# check BLAS
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

	# check LAPACK
	if use lapack; then
		eselect lapack add ${libdir} "${EROOT}"/usr/${libdir}/lapack/${me} ${me}
		local current_lapack=$(eselect lapack show ${libdir} | cut -d' ' -f2)
		if [[ ${current_lapack} == "${me}" || -z ${current_lapack} ]]; then
			eselect lapack set ${libdir} ${me}
			elog "Current eselect: LAPACK/LAPACKE ($libdir) -> [${current_lapack}]."
		else
			elog "Current eselect: LAPACK/LAPACKE ($libdir) -> [${current_lapack}]."
			elog "To use lapack [${me}] implementation, you have to issue (as root):"
			elog "\t eselect lapack set ${libdir} ${me}"
		fi
	fi
}

pkg_postrm() {
	if use eselect-ldso; then
		eselect blas validate
		if use lapack; then eselect lapack validate; fi
	fi
}
