# Copyright 2019-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1

inherit cmake python-single-r1

DESCRIPTION="A high level and feature rich audio library written in C++ with language bindings"
HOMEPAGE="https://audaspace.github.io"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neXyon/audaspace"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	SRC_URI="https://github.com/neXyon/audaspace/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="doc examples +python jack +fftw +ffmpeg +sdl +sndfile +openal pulseaudio"

BDEPEND="
	virtual/libc
	sdl? ( media-libs/libsdl2[sound] )
	sndfile? ( media-libs/libsndfile )
	ffmpeg? ( media-video/ffmpeg:=[mp3,encode,theora,vorbis,opus] )
	fftw? ( sci-libs/fftw:3.0= )
	jack? ( virtual/jack )
	openal? ( media-libs/openal )
	pulseaudio? ( media-libs/libpulse )
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx[latex]
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="mirror"


pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	find "${S}" -name "*.py" | while read x; do
		sed -i -e "/^#!/s/python\(.*\)/python/" "$x" || die
	done

	use python && python_fix_shebang -q "${S}"

	cmake_src_prepare
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PF}"
		-DWITH_OPENAL=$(usex openal)
		-DWITH_JACK=$(usex jack)
		-DWITH_PYTHON=$(usex python)
		-DWITH_FFTW=$(usex fftw)
		-DWITH_FFMPEG=$(usex ffmpeg)
		-DWITH_PULSEAUDIO=$(usex pulseaudio)
		-DWITH_DOCS=$(usex doc)
		-DWITH_SDL=$(usex sdl)
		-DBUILD_DEMOS=$(usex examples)
		-DDEFAULT_PLUGIN_PATH="/usr/share/audaspace/plugins"
	)
	use python && mycmakeargs+=(
		-DPYTHON_EXECUTABLE="${PYTHON}"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_optimize
}
