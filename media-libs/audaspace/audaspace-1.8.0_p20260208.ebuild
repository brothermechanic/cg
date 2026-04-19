# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..14} )
DISTUTILS_OPTIONAL=1
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
DISTUTILS_EXT=1

inherit cmake distutils-r1 flag-o-matic

DESCRIPTION="A high level and feature rich audio library written in C++ with language bindings"
HOMEPAGE="https://audaspace.github.io"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/neXyon/audaspace"
	EGIT_BRANCH="master"
	EGIT_SUBMODULES=()
	KEYWORDS=""
else
	COMMIT="7b04aa90fc746c0ea80e876cd7c9964ae523b910"
	SRC_URI="https://github.com/neXyon/audaspace/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
	S=${WORKDIR}/${PN}-${COMMIT}
	KEYWORDS="~amd64 ~x86 ~arm64 ~arm"
fi

LICENSE="Apache-2.0"
SLOT="0"
IUSE="doc examples +python jack +fftw +ffmpeg sdl +sndfile openal pipewire pulseaudio +rubberband"

RDEPEND="python? ( ${PYTHON_DEPS} )"
BDEPEND="
	virtual/libc
	virtual/pkgconfig
	sdl? ( media-libs/libsdl2[sound] )
	sndfile? ( media-libs/libsndfile[alsa,-minimal] )
	ffmpeg? (
		<media-video/ffmpeg-9:=[lame,theora,vorbis,opus]
		>media-video/ffmpeg-5:=[lame,theora,vorbis,opus]
	)
	fftw? ( sci-libs/fftw:3.0= )
	jack? ( virtual/jack )
	openal? ( media-libs/openal )
	pulseaudio? ( media-libs/libpulse )
	rubberband? ( media-libs/rubberband )
	pipewire? ( media-video/pipewire )
	doc? (
		app-text/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx[latex]
	)
	python? (
		${PYTHON_DEPS}
		${DISTUTILS_DEPS}
		$(python_gen_cond_dep '
			dev-python/numpy[${PYTHON_USEDEP}]
		')
	)
"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

RESTRICT="mirror"

wrap_python() {
	local phase=$1
	shift
	if use python; then
		pushd bindings/python >/dev/null || die
		top_builddir="../.." srcdir="${S}/bindings/python" distutils-r1_${phase} "$@"
		popd >/dev/null || die
	fi
}

pkg_setup() {
	use python && python_setup
}

src_prepare() {
	# Shebang
	find "${S}" -name "*.py" | while read x; do
		sed -i -e "/^#!/s/python\(.*\)/python/" "$x" || die
	done

	use python && python_fix_shebang -q "${S}"

	cmake_src_prepare
	wrap_python ${FUNCNAME}
}

src_configure() {
	CMAKE_BUILD_TYPE=Release
	append-cppflags -std=c++20
	local mycmakeargs=(
		-DCMAKE_POLICY_DEFAULT_CMP0148="OLD"
		-DCMAKE_INSTALL_LIBDIR="$(get_libdir)"
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DWITH_STRICT_DEPENDENCIES=YES
		# LIBS
		-DWITH_FFTW=$(usex fftw)
		-DWITH_SDL=$(usex sdl)
		-DWITH_RUBBERBAND=$(usex rubberband)

		# PLUGINS
		-DWITH_OPENAL=$(usex openal)
		-DWITH_JACK=$(usex jack)
		-DWITH_FFMPEG=$(usex ffmpeg)
		-DWITH_PULSEAUDIO=$(usex pulseaudio)
		-DWITH_PIPEWIRE=$(usex pipewire)
		-DWITH_LIBSNDFILE=$(usex sndfile)
		-DDEFAULT_PLUGIN_PATH="/usr/share/audaspace/plugins"

		# BINDIGS
		-DDOCUMENTATION_INSTALL_PATH="/usr/share/doc/${PF}"
		-DWITH_DOCS=$(usex doc)
		-DWITH_PYTHON=$(usex python)
		-DWITH_C=YES
		-DSEPARATE_C=YES

		-DBUILD_DEMOS=$(usex examples)
	)
	use python && mycmakeargs+=(
		-DPYTHON_EXECUTABLE="${PYTHON}"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DNUMPY_INCLUDE_DIR="$(python_get_sitedir)/numpy/_core/include"
	)
	DISTUTILS_ARGS=(
		$(usex doc "--build-docs" "")
	)
	export OMP_NUM_THREADS=1
	cmake_src_configure
	wrap_python ${FUNCNAME}
}

src_install(){
	addpredict /dev/snd
	cmake_src_install
	if use python; then
		rm -rf "${D}/$(python_get_sitedir)"/*.egg-info || die
		python_optimize
	fi
}
