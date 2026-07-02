# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..14} )

inherit python-any-r1
inherit flag-o-matic meson toolchain-funcs

DESCRIPTION="Pure C implementation of the venerable F77 LAPACK library"
HOMEPAGE="https://ilayn.github.io/semicolon-lapack"

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/ilayn/semicolon-lapack.git"
else
	COMMIT="b298d10082a1a0c5974993f5f20b1e7323e39f1e"
	SRC_URI="https://github.com/ilayn/semicolon-lapack/archive/${COMMIT}.tar.gz -> ${P}.gh.tar.gz"
	KEYWORDS="~amd64 ~arm64 ~arm ~x86"
	S="${WORKDIR}"/${PN}-${COMMIT}
fi

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~loong ~ppc ppc64 ~riscv ~x86 ~x64-macos"
IUSE="benchmark debug doc eselect-ldso fortran index64 openmp pthread static-libs test"
REQUIRED_USE="
	?? ( openmp pthread )
"
RESTRICT="
	!test? ( test )
	mirror
"

COMMON_DEPEND="
	virtual/cblas[index64(-)=]
"

RDEPEND="
	${COMMON_DEPEND}
	eselect-ldso? (
		>=app-eselect/eselect-lapack-0.2
	)
"

BDEPEND="
	${COMMON_DEPEND}
	virtual/pkgconfig
	doc? (
		app-text/doxygen
		$(python_gen_any_dep '
			dev-python/breathe[${PYTHON_USEDEP}]
			dev-python/sphinx[${PYTHON_USEDEP}]
			dev-python/sphinx-rtd-theme[${PYTHON_USEDEP}]
		')
	)
	test? ( dev-util/cmocka )
"

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

src_configure() {
	filter-lto

	local emesonargs=(
		$(meson_use test tests)
		$(meson_use benchmark benchmarks)
		$(meson_use fortran fabi_shim)
		$(meson_use index64 USE_INT64)
		-Dblas=$(usex index64 "cblas64" "cblas") #
	)

	meson_src_configure
}

src_compile() {
	meson_src_compile
	use doc && emake -C docs html
}

src_install() {
	dodoc LAPACK_divergence.txt README.md
	meson_src_install
	use doc && HTML_DOCS=( docs/build/html/* )
	use eselect-ldso || return
	local libdir="$(get_libdir)" me="${PN}"
	# Create private lib directory for eselect::blas (ld.so.conf)
	dodir "/usr/${libdir}/lapack/${me}"
	cp -v "${ED}/usr/${libdir}/libsemilapack.so" \
	    "${ED}/usr/${libdir}/lapack/${me}/liblapacke.so.3"
	dosym "liblapacke.so.3" "/usr/${libdir}/lapack/${me}/liblapacke.so"

	use fortran || return
	local libdir="$(get_libdir)" me="${PN}"
	# Create private lib directory for eselect::blas (ld.so.conf)
	dodir "/usr/${libdir}/lapack/${me}"
	cp -v "${ED}/usr/${libdir}/libsemilapack_fortran.so" \
	    "${ED}/usr/${libdir}/lapack/${me}/liblapack.so.3"
	dosym "liblapack.so.3" "/usr/${libdir}/lapack/${me}/liblapack.so"
}

pkg_postinst() {
	use eselect-ldso || return
	local libdir=$(get_libdir) me="${PN}"

	# check lapack
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
}

pkg_postrm() {
	if use eselect-ldso; then
		eselect lapack validate
	fi
}
