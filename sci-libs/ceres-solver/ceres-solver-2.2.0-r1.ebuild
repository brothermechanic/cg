# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
DOCS_BUILDER="sphinx"
DOCS_DEPEND="dev-python/sphinx-rtd-theme"
DOCS_DIR="docs/source"
inherit cmake-multilib cuda flag-o-matic python-any-r1 docs toolchain-funcs

DESCRIPTION="Nonlinear least-squares minimizer"
HOMEPAGE="http://ceres-solver.org/"
SRC_URI="https://github.com/${PN}/${PN}/archive/${PV}.tar.gz"

LICENSE="sparse? ( BSD ) !sparse? ( LGPL-2.1 )"
SLOT="0/4" # Based on soname libceres.so.4
KEYWORDS="amd64 ~x86 ~amd64-linux ~x86-linux"

CUDA_TARGETS_COMPAT=( sm_30 sm_35 sm_50 sm_52 sm_61 sm_70 sm_75 sm_86 sm_87 sm_89 sm_90 )
IUSE="cuda debug doc examples gflags lapack metis openmp +schur sparse test ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"
RESTRICT="
	mirror
	!test? ( test )
"

REQUIRED_USE="test? ( gflags ) sparse? ( lapack ) abi_x86_32? ( !sparse !lapack )"
RESTRICT="!test? ( test )"

BDEPEND="${PYTHON_DEPS}
	>=dev-cpp/eigen-3.3.4:3
	lapack? ( virtual/pkgconfig )
	doc? ( <dev-libs/mathjax-3 )
"
RDEPEND="
	dev-cpp/glog[gflags?,${MULTILIB_USEDEP}]
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	lapack? ( virtual/lapack )
	metis? ( sci-libs/metis[-int64] )
	sparse? (
		sci-libs/cxsparse
		sci-libs/amd
		sci-libs/camd
		sci-libs/ccolamd
		sci-libs/cholmod[metis(+)]
		sci-libs/colamd
		sci-libs/spqr
	)
"
DEPEND="${RDEPEND}"

DOCS=( README.md )

PATCHES=(
	"${FILESDIR}/${PN}-2.0.0-system-mathjax.patch"
)

pkg_pretend() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
}

pkg_setup() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp
	use doc && python-any-r1_pkg_setup
}

src_prepare() {
	cmake_src_prepare

	use cuda && cuda_src_prepare

	# search paths work for prefix
	sed -e "s:/usr:${EPREFIX}/usr:g" \
		-i cmake/*.cmake || die

	# remove Werror
	sed -e 's/-Werror=(all|extra)//g' \
		-i CMakeLists.txt || die
}

src_configure() {
	# CUSTOM_BLAS=OFF EIGENSPARSE=OFF MINIGLOG=OFF
	local mycmakeargs=(
		-DBUILD_BENCHMARKS=OFF
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTING=$(usex test)
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DCUSTOM_BLAS="yes"
		-DMINIGLOG="no"
		-DBUILD_SHARED_LIBS=ON
		-DUSE_CUDA=$(usex cuda)
		-DEIGENMETIS=$(usex metis)
		-DGFLAGS=$(usex gflags)
		-DLAPACK=$(usex lapack)
		-DSCHUR_SPECIALIZATIONS=$(usex schur)
		-DSUITESPARSE=$(usex sparse)
		-DEIGENSPARSE=$(usex sparse)
		-DEigen3_DIR=/usr/$(get_libdir)/cmake/eigen3
		-DCERES_THREADING_MODEL=$(usex openmp OPENMP CXX_THREADS)
	)

	use doc && mycmakeargs+=(
		-DCERES_DOCS_INSTALL_DIR="${EPREFIX}"/usr/share/doc/${PF}
	)

	if use cuda; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT##sm_}-real;"
		done
		mycmakeargs+=(
			-DCMAKE_CUDA_ARCHITECTURES="${CUDA_TARGETS%%;}"
		)
		: "${CUDAHOSTCXX:=$(cuda_gccdir)}"
		: "${CUDAARCHS:=all}"
		export CUDAHOSTCXX
		export CUDAARCHS
	fi

	cmake-multilib_src_configure
}

src_test() {
	use cuda && cuda_add_sandbox -w
	cmake_src_test
}

src_install() {
	cmake-multilib_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		dodoc -r examples data
	fi
}
