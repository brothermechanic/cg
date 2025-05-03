# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# This ebuild exists to prevent:
# ImportError: /usr/lib64/libjemalloc.so.2: cannot allocate memory in static TLS block
# for openusd ebuild-package.

# Same as jemalloc ebuild from gentoo-overlay but with the mtls-dialect-gnu
# patch.

# PGOing this library is justified because the size of the library is over a
# 1000 4k pages in size.

TRAIN_TEST_DURATION=1800 # 30 min
inherit autotools multilib-minimal flag-o-matic

MY_PN="jemalloc"
DESCRIPTION="USD support for Jemalloc, a general-purpose scalable concurrent allocator"
HOMEPAGE="http://jemalloc.net/ https://github.com/jemalloc/jemalloc"
LICENSE="BSD-2"
SLOT="0/2"
KEYWORDS+=" amd64 arm arm64 hppa ~loong ~m68k ppc ppc64 ~riscv ~s390 ~sparc x86"
TRAINERS=(
	"test-trainer"
	"stress-test-trainer"
)
IUSE+=" ${TRAINERS[@]}"
IUSE+=" custom-cflags debug doc lazy-lock pgo prof static-libs stats test xmalloc"
REQUIRED_USE+="
	pgo? ( || ( ${TRAINERS[@]} ) custom-cflags )
	test-trainer? ( pgo )
	stress-test-trainer? ( pgo )
"
SRC_URI="https://github.com/jemalloc/jemalloc/releases/download/${PV}/${MY_PN}-${PV}.tar.bz2"
PATCHES=(
	"${FILESDIR}/${MY_PN}-5.2.1-mtls-dialect-gnu2-7036e64.patch"
	"${FILESDIR}/${MY_PN}-5.3.0-backport-pr-2312.patch"
	"${FILESDIR}/${MY_PN}-5.3.0-backport-pr-2338.patch"
)
S="${WORKDIR}/${MY_PN}-${PV}"
MULTILIB_WRAPPED_HEADERS=( /usr/include/jemalloc/jemalloc.h )

src_prepare() {
	default

	if use custom-cflags ; then
		eapply "${FILESDIR}/${MY_PN}-5.3.0-gentoo-fixups.patch"
		# -g3 flag introduced in f3340ca8d5b89ce8f2ec5b3721871029e0fa70ac (circa 2009) : Add configure tests for CFLAGS settings.
		if ! use test ; then
			sed -i -e "/-g3/d" configure.ac || die
		fi
	else
		strip-flags
		filter-flags -O*
	fi

	eautoreconf

	prepare_abi() {
		cp -a "${S}" "${S}-${MULTILIB_ABI_FLAG}.${ABI}" || die
	}
	multilib_foreach_abi prepare_abi
}

_add_gcov() {
	local d="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
	local f
	for f in Makefile Makefile.in ; do
einfo "Editing ${f}:  Adding -lgcov"
		sed -i -e "s|EXTRA_LDFLAGS :=|EXTRA_LDFLAGS := -lgcov|g" \
			"${d}/${f}" || die
	done
}

_remove_gcov() {
	local d="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
	local f
	for f in Makefile Makefile.in ; do
einfo "Editing ${f}:  Removing -lgcov"
		sed -i -e "s|EXTRA_LDFLAGS := -lgcov|EXTRA_LDFLAGS :=|g" \
			"${d}/${f}" || die
	done
}

multilib_src_configure() {
	filter-flags -fprofile-arcs
	if [[ "${PGO_PHASE}" == "PGI" ]] ; then
		append-flags -fprofile-arcs
	fi
	if [[ "${PGO_PHASE}" == "PGO" ]] ; then
		tc-is-gcc && append-flags -Wno-error=coverage-mismatch
	fi
	local myconf=(
		--prefix=/usr/$(get_libdir)/openusd
		$(use_enable debug)
		$(use_enable lazy-lock)
		$(use_enable prof)
		$(use_enable stats)
		$(use_enable xmalloc)
	)
	ECONF_SOURCE="${S}-${MULTILIB_ABI_FLAG}.${ABI}" econf "${myconf[@]}"
	[[ "${PGO_PHASE}" == "PGI" ]] && _add_gcov
	[[ "${PGO_PHASE}" == "PGO" ]] && _remove_gcov
}

src_compile() {
	compile_abi() {
		BUILD_DIR="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
		cd "${BUILD_DIR}" || die
	}
	multilib_foreach_abi compile_abi
}

_test_trainer_wrapper() {
	local use_id="test-trainer"
	local d="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
cat <<EOF > "${d}/${use_id}" || die
#!${EPREFIX}/bin/bash
cd "${d}"
make check || true
EOF
chmod +x "${d}/${use_id}" || die
}

_stress_test_trainer_wrapper() {
	local use_id="stress-test-trainer"
	local d="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
cat <<EOF > "${d}/${use_id}" || die
#!${EPREFIX}/bin/bash
cd "${d}"
make stress || true
EOF
chmod +x "${d}/${use_id}" || die
}

_src_pre_train() {
	use test-trainer && _test_trainer_wrapper
	use stress-test-trainer && _stress_test_trainer_wrapper
}

train_trainer_list() {
	use test-trainer && echo "test-trainer"
	use stress-test-trainer && echo "stress-test-trainer"
}

train_get_trainer_exe() {
	local trainer="${1}"
	local s="${S}-${MULTILIB_ABI_FLAG}.${ABI}"
	echo "${s}/${trainer}"
}

train_override_duration() {
	local trainer="${1}"
	# 10 min slack is added for older computers.
	if [[ "${trainer}" == "test-trainer" ]] ; then
# real	10m40.282s
# user	8m57.655s
# sys	0m38.096s
		echo "1260" # 21 min
	elif [[ "${trainer}" == "stress-test-trainer" ]] ; then
# real	16m35.275s
# user	14m33.077s
# sys	0m17.290s
		echo "1620" # 27 min
	else
		echo "1800" # 30 min
	fi
}

multilib_src_test() {
	emake check
	emake stress
}

multilib_src_install() {
	#use doc && HTML_DOCS=( ${BUILD_DIR}/doc/jemalloc.html )
	# Copy man file which the Makefile looks for
	cp "${S}/doc/jemalloc.3" "${BUILD_DIR}/doc" || die
	emake DESTDIR="${D}" install
}

multilib_src_install_all() {
	if [[ "${CHOST}" == *"-darwin"* ]] ; then
		# fixup install_name, #437362
		install_name_tool \
			-id "${EPREFIX}/usr/$(get_libdir)/libjemalloc.2.dylib" \
			"${ED}/usr/$(get_libdir)/libjemalloc.2.dylib" || die
	fi
	use static-libs || find "${ED}" -name '*.a' -delete
	rm -rf "${ED}/usr/share/man" || die
}

