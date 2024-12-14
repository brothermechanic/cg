# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
LLVM_COMPAT=( 18 19 )
inherit llvm-r1 python-single-r1 flag-o-matic java-pkg-opt-2 toolchain-funcs

DESCRIPTION="Compile C and C++ LLVM Bytecode into highly-optimizable JavaScript for the web"
HOMEPAGE="https://emscripten.org"
SRC_URI="https://github.com/emscripten-core/emscripten/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="java python llvm_targets_WebAssembly"

REQUIRED_USE="llvm_targets_WebAssembly"

RDEPEND="
	${PYTHON_DEPS}
	dev-util/binaryen
    net-libs/nodejs[npm]
	sys-apps/which
	python? ( dev-lang/python )
	java? ( virtual/jre )
"
BDEPEND="
   $(llvm_gen_dep '
     llvm-core/clang:${LLVM_SLOT}=
     llvm-core/llvm:${LLVM_SLOT}=
   ')
	dev-build/cmake
	dev-libs/libxml2
	dev-vcs/git
	dev-build/ninja
	java? ( virtual/jdk )
"

RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/${PN}-3.1.28-libcxxabi_no_exceptions-already-defined.patch"
	"${FILESDIR}/${PN}-3.1.51-set-wrappers-path.patch"
	"${FILESDIR}/${PN}-3.1.51-includes.patch"
	"${FILESDIR}/${PN}-3.1.67-py-runner.patch"
)

pkg_setup() {
	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
	llvm-r1_pkg_setup
	strip-unsupported-flags
}

src_prepare() {
	export PYTHON_EXE_ABSPATH="${EPYTHON}"
	einfo "PYTHON_EXE_ABSPATH=${PYTHON_EXE_ABSPATH}"
	use java && java-pkg-opt-2_src_prepare
	sed -e "/{/a\"name\": \"${PN}\"," -i "${S}/package.json" || die
	sed -e "s|GENTOO_PREFIX|${EPREFIX}|" -e "s|GENTOO_LIB|$(get_libdir)|" -e "s|GENTOO_LLVM_VERSION|${MY_LLVM_VERSION}|" < "${FILESDIR}/config" > .emscripten || die
	sed -e "s|GENTOO_PREFIX|${EPREFIX}|" -e "s|GENTOO_LIB|$(get_libdir)|" -e "s|GENTOO_PYTHON|${EPYTHON}|" -i tools/shared.py tools/run_python.sh tools/run_python_compiler
	default
}

src_compile() {
	:
}

NPM_FLAGS=(
	--audit false
	--color false
	--foreground-scripts
	--global
	--offline
	--progress false
	--save false
	--verbose
)

src_install() {
	dodir /usr/bin
	tools/maint/create_entry_points.py || die "Script failed."
	find "${S}" \
	\( \
		-path "*/test/third_party/*" \
		-o -name "test" \
		-o -name "*.bat" \
		-o -name "*.ps1" \
		-o -name "site" \
		-o -name "Makefile" \
		-o -name ".git" \
		-o -name "cache" \
		-o -name "cache.lock" \
		-o -name "*.pyc" \
		-o \( \
			     -name ".*" \
			-not -name ".bin" \
		   \) \
		-o -name "__pycache__" \
	\) \
		-exec rm -vrf "{}" \;
	npm "${NPM_FLAGS[@]}" \
		--prefix "${ED}"/usr \
		install --omit=dev || die
	insinto "/usr/$(get_libdir)/emscripten"
	doins -r .
	chmod +x "${ED}/usr/$(get_libdir)/emscripten/tools"/* || die
	chmod +x "${ED}/usr/$(get_libdir)/emscripten"/* || die
	chmod +x "${ED}/usr/bin"
}
