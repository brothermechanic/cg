# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_9 )

inherit cmake python-single-r1

DESCRIPTION="Automatic 3d tetrahedal mesh generator"
HOMEPAGE="https://ngsolve.org/"
SRC_URI="https://github.com/NGSolve/netgen/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="LGPL-2.1"

SLOT="0"
KEYWORDS="~amd64 ~x86"

# opencascade not supported upstream
IUSE="ffmpeg +gui jpeg mpi opencascade +python"

#	dev-tcltk/tix:=
#	dev-tcltk/togl:0=
RDEPEND="
	${PYTHON_DEPS}
	>=dev-lang/tcl-8.5:=[threads(+)]
	>=dev-lang/tk-8.5:=[threads(+)]
	sys-libs/zlib:=
	virtual/glu
	virtual/opengl
	x11-libs/libICE:=
	x11-libs/libX11:=
	x11-libs/libXext:=
	x11-libs/libXmu:=
	ffmpeg? ( virtual/ffmpeg )
	jpeg? ( virtual/jpeg:0= )
	python? (
		$(python_gen_cond_dep \
			'dev-python/pybind11[${PYTHON_USEDEP}]')
	)
	mpi? (
		>=sci-libs/parmetis-4.0.3:=[mpi?]
		virtual/mpi[cxx,threads]
		opencascade? ( >=sci-libs/hdf5-1.10.5:=[mpi] )
	)
	opencascade? ( >=sci-libs/opencascade-7.3.0:=[ffmpeg?] )
"
DEPEND="${RDEPEND}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}"/${P}-0001-CMakeLists.txt-Gentoo-specific-patches.patch
	"${FILESDIR}"/${P}-0002-ng-Togl2.1-CMakeLists.txt-Gentoo-specific-fixes.patch
	"${FILESDIR}"/${P}-0003-CMakeLists.txt-find-external-pybind11.patch
)

DOCS=( AUTHORS NEWS README.md TODO )

src_prepare() {
	cmake_src_prepare

	cp "${S}"/doc/ng4.pdf "${S}" || die "failed to copy documentation PDF"
}

src_configure() {
	mycmakeargs=(
		-DBUILD_FOR_CONDA=OFF # default
		-DBUILD_STUB_FILES=OFF # pybind11 doesn't install binaries, this requires a pybind11-stubs executable
		-DCHECK_RANGE=OFF # FIXME: check array range acces, auto-enabled if debug build
		-DDEBUG_LOG=OFF # FIXME: enable more debug output (requires USE_SPDLOG=ON), useful for debug USE flag?
		-DENABLE_UNIT_TESTS=OFF # FIXME: test them (needs dev-cpp/catch)
		-DENABLE_CPP_CORE_GUIDELINES_CHECK=OFF # FIXME: useful for debug USE flag? Requires clang-tidy
		-DINSTALL_PROFILES=ON
		-DINTEL_MIC=OFF # FIXME: add intel xeon phi cross compile support? needs mkl
		-DUSE_CCACHE=OFF
		-DUSE_GUI=$(usex gui)
		-DUSE_INTERNAL_TCL=OFF
		-DUSE_JPEG=$(usex jpeg)
		-DUSE_MPEG=$(usex ffmpeg)
		-DUSE_MPI=$(usex mpi)
		-DUSE_OCC=$(usex opencascade)
		-DUSE_PYTHON=$(usex python)
		-DUSE_SPDLOG=OFF # FIXME: enables SPD log logging
		-DUSE_SUPERBUILD=OFF
	)

	if use opencascade; then
		mycmakeargs+=(
			-DOCC_INCLUDE_DIR="${CASROOT}"/include/opencascade
			-DOCC_LIBRARY_DIR="${CASROOT}"/$(get_libdir)
		)
	fi

	if use mpi; then
		export CC=mpicc
		export CXX=mpicxx
		export FC=mpif90
		export F90=mpif90
		export F77=mpif77
	fi

	# internal togl needs tkInt.h
#	append-cppflags " \
#		-I/usr/$(get_libdir)/tk8.6/include/generic \
#		-I/usr/$(get_libdir)/tk8.6/include/unix \
#	"

	cmake_src_configure
}

src_install() {
	cmake_src_install

	use python && python_optimize

	dosym ../../${PN}/doc/ng4.pdf /usr/share/doc/${PF}/ng4.pdf
}

pkg_postinst() {
	einfo "Remember to run env-update && source /etc/profile"
	einfo "NOTE: opencascade is currently not tested!"
}
