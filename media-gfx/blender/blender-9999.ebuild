# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
OPENVDB_COMPAT=( {7..11} )
LLVM_COMPAT=( 17 18 )
LLVM_OPTIONAL=1

inherit check-reqs cmake cuda flag-o-matic git-r3 pax-utils python-single-r1 toolchain-funcs xdg-utils llvm-r1 openvdb cg-blender-scripts-dir

DESCRIPTION="Blender is a free and open-source 3D creation suite."
HOMEPAGE="https://www.blender.org"

EGIT_REPO_URI="https://projects.blender.org/blender/blender.git"
EGIT_REPO_URI_LIST="https://projects.blender.org/blender/blender-addons.git https://projects.blender.org/blender/blender-addons-contrib.git"
EGIT_SUBMODULES=()
if [[ ${PV} == 9999 ]]; then
	EGIT_BRANCH="main"
	EGIT_COMMIT="463a4c6211e5df2fa7e2a9a9ca8347262266c44e"
	#EGIT_COMMIT="8f09fffef7a2fad67c8111b31c9bd0206657f26c"
	#EGIT_CLONE_TYPE="shallow"
	MY_PV="4.2"
	KEYWORDS=""
else
	MY_PV="$(ver_cut 1-2)"
	EGIT_BRANCH="blender-v${MY_PV}-release"
	#EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm ~arm64"
fi

[[ "4.0 3.6" =~ "${MY_PV}"  ]] && OSL_PV="12" || OSL_PV="13"
[[ "${MY_PV}" == "4.2"  ]] && AUD_PV="1.5.1" || AUD_PV="1.4.1"

SLOT="$MY_PV"
LICENSE="|| ( GPL-3 BL )"

CUDA_TARGETS_COMPAT=(
	sm_30
	sm_35
	sm_37
	sm_50
	sm_52
	sm_60
	sm_61
	sm_70
	sm_75
	sm_86
	sm_89
	compute_89
)

AMDGPU_TARGETS_COMPAT=(
	gfx900
	gfx90c
	gfx902
	gfx1010
	gfx1011
	gfx1012
	gfx1030
	gfx1031
	gfx1032
	gfx1034
	gfx1035
	gfx1100
	gfx1101
	gfx1102
)

IUSE_CPU="+openmp +simd +tbb -lld -gold +mold -cpu_flags_arm_neon llvm -valgrind +jemalloc"
IUSE_GPU="cuda optix rocm oneapi -cycles-bin-kernels ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_} ${AMDGPU_TARGETS_COMPAT[@]/#/amdgpu_targets_}"
IUSE_DESKTOP="+cg -portable +X headless +nls -ndof wayland vulkan"
IUSE_LIBS="+bullet +boost +draco +materialx +color-management +oidn +opensubdiv +openvdb nanovdb openxr +libmv +freestyle lzma lzo"
IUSE_MOD="+fluid +smoke +oceansim +remesh +gmp +quadriflow"
IUSE_RENDER="+cycles osl +openpgl +embree +pugixml +potrace +fftw"
IUSE_3DFILES="-alembic -usd +collada +obj +ply +stl"
IUSE_IMAGE="-dpx +openexr jpeg2k webp +pdf"
IUSE_CODEC="avi +ffmpeg flac -sndfile +quicktime aom mp3 opus theora vorbis vpx x264 xvid"
IUSE_SOUND="jack openal -pulseaudio sdl"
IUSE_TEST="-debug -doc -man -gtests -test icu"

IUSE="${IUSE_CPU} ${IUSE_GPU} ${IUSE_DESKTOP} ${IUSE_LIBS} ${IUSE_MOD} ${IUSE_RENDER} ${IUSE_3DFILES} ${IUSE_IMAGE} ${IUSE_CODEC} ${IUSE_SOUND} ${IUSE_TEST}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	^^ ( gold lld mold )
	|| ( wayland X )
	!boost? ( !alembic !color-management !cycles !nls !openvdb )
	alembic? ( openexr )
	embree? ( cycles tbb )
	smoke? ( fftw )
	cuda? ( cycles )
	optix? ( cuda )
	fluid? ( fftw tbb )
	nanovdb? ( cuda )
	materialx? (
		!python_single_target_python3_10
		python_single_target_python3_11
	)
	oceansim? ( fftw )
	oidn? ( cycles tbb )
	oneapi? ( cycles )
	optix? ( cycles )
	openvdb? ( ${OPENVDB_REQUIRED_USE} cycles tbb )
	opensubdiv? ( X )
	osl? ( cycles llvm pugixml )
	rocm? ( cycles llvm )
	vulkan? ( llvm )
	test? ( gtests color-management )
	usd? ( tbb )
"

LANGS="en ab ar be bg ca cs da de el eo es es_ES eu fa fi fr ha he hi hr hu id it ja ka km ko ky ne nl pl pt_BR pt ru sk sr@latin sr sv sw ta th tr zh_TW uk vi zh_CN zh_HANS zh_HANT"

for X in ${LANGS} ; do
	IUSE+=" l10n_${X}"
	REQUIRED_USE+=" l10n_${X}? ( nls )"
done

CODECS="
	aom? (
		>=media-libs/libaom-3.3.0
	)
	mp3? (
		>=media-sound/lame-3.100[sndfile]
	)
	opus? (
		>=media-libs/opus-1.3.1
	)
	theora? (
		>=media-libs/libogg-1.3.5
		>=media-libs/libtheora-1.1.1
		vorbis? (
			>=media-libs/libtheora-1.1.1[encode]
		)
	)
	vorbis? (
		>=media-libs/libogg-1.3.5
		>=media-libs/libvorbis-1.3.7
	)
	vpx? (
		>=media-libs/libvpx-1.11
	)
	x264? (
		>=media-libs/x264-0.0.20220221
	)
	xvid? (
		>=media-libs/xvid-1.3.7
	)
"

RDEPEND="
	${CODECS}
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-libs/boost[nls?,icu?,threads(+),python,${PYTHON_USEDEP}]
		>=dev-python/certifi-2021.10.8[${PYTHON_USEDEP}]
		>=dev-python/charset-normalizer-2.0.6[${PYTHON_USEDEP}]
		>=dev-python/idna-3.2[${PYTHON_USEDEP}]
		>=dev-python/numpy-1.24.3[${PYTHON_USEDEP}]
		>=dev-python/pybind11-2.10.1[${PYTHON_USEDEP}]
		>=dev-python/zstandard-0.16.0[${PYTHON_USEDEP}]
		>=dev-python/requests-2.26.0[${PYTHON_USEDEP}]
		>=dev-python/urllib3-1.26.7[${PYTHON_USEDEP}]
	')
	>=dev-cpp/nlohmann_json-3.10.0:=
	media-libs/freetype:=[brotli,bzip2,harfbuzz,png]
	media-libs/libepoxy:=
	>=dev-cpp/pystring-1.1.3
	>=dev-libs/fribidi-1.0.12
	>=media-libs/libpng-1.6.37:0=
	>=sys-libs/minizip-ng-3.0.7
	>=sys-libs/zlib-1.2.13
	dev-libs/lzo:2
	media-libs/libglvnd
	media-libs/libsamplerate
	virtual/libintl
	alembic? ( >=media-gfx/alembic-1.8.3-r2[boost(+),hdf5(+)] )
	collada? ( >=media-libs/opencollada-1.6.68 )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	draco? ( >=media-libs/draco-1.5.2:= )
	embree? (
		>=media-libs/embree-3.1.0[raymask,tbb?]
		<media-libs/embree-5
	)
	rocm? ( >=dev-util/hip-5.4.0 )
	ffmpeg? (
		<media-video/ffmpeg-7:=[encode,jpeg2k?,mp3?,opus?,sdl,theora?,vorbis?,vpx?,x264?,xvid?,zlib]
		>media-video/ffmpeg-5:=[encode,jpeg2k?,mp3?,opus?,sdl,theora?,vorbis?,vpx?,x264?,xvid?,zlib]
	)
	fftw? ( sci-libs/fftw:3.0=[openmp?] )
	flac? (	>=media-libs/flac-1.4.2	)
	gmp? ( >=dev-libs/gmp-6.2.1[cxx] )
	dev-cpp/gflags:=
	gtests? (
		dev-cpp/glog:=[gflags]
		dev-cpp/gmock:=
	)
	jack? ( virtual/jack )
	jemalloc? ( dev-libs/jemalloc:= )
	jpeg2k? ( media-libs/openjpeg:2= )
	libmv? ( sci-libs/ceres-solver:= )
	lzo? ( dev-libs/lzo:2= )
	ndof? (
		>=dev-libs/libspnav-1.1
		app-misc/spacenavd
	)
	materialx? (
		>=media-libs/materialx-1.38.8[${PYTHON_SINGLE_USEDEP},python]
	)
	nls? ( virtual/libiconv )
	<=media-libs/audaspace-${AUD_PV}:=[python,openal?,sdl?,pulseaudio?]
	oneapi? (
		sys-devel/DPC++
	)
	openal? (
		>=media-libs/openal-1.23.1
	)
	media-libs/glew:*
	oidn? ( >=media-libs/oidn-2.1.0[cuda?] )
	<media-libs/openimageio-2.6[${PYTHON_SINGLE_USEDEP},${OPENVDB_SINGLE_USEDEP},python,color-management?]
	>=media-libs/openimageio-2.5.6.0[${PYTHON_SINGLE_USEDEP},${OPENVDB_SINGLE_USEDEP},python,color-management?]
	>=dev-cpp/robin-map-0.6.2
	>=dev-libs/libfmt-9.1.0
	color-management? ( >=media-libs/opencolorio-2.3.0:= )
	openexr? ( >=media-libs/openexr-3.2.1:= )
	openpgl? (
		<media-libs/openpgl-0.6[tbb?]
		>=media-libs/openpgl-0.5[tbb?]
	)
	opensubdiv? ( >=media-libs/opensubdiv-3.6.0[cuda?,openmp?,tbb?,opengl] )
	openvdb? (
		>=media-gfx/openvdb-9.0.0:=[${OPENVDB_SINGLE_USEDEP},cuda?,nanovdb?]
		<=media-gfx/openvdb-12.0.0:=[${OPENVDB_SINGLE_USEDEP},cuda?,nanovdb?]
		>=dev-libs/c-blosc-1.21.1[zlib]
		nanovdb? (
			>=media-gfx/nanovdb-32:0=
			<media-gfx/nanovdb-32.6.0:0=
		)
	)
	openxr? (
		>=media-libs/openxr-1.0.17
	)
	optix? (
		>=dev-libs/optix-7.5.0
	)
	osl? (
		>=media-libs/osl-1.${OSL_PV}:=[optix?]
		<media-libs/osl-1.$((${OSL_PV}+1)):=[optix?]
	)
	pdf? ( >=media-libs/libharu-2.3.0 )
	potrace? ( >=media-gfx/potrace-1.16 )
	pugixml? ( dev-libs/pugixml )
	pulseaudio? ( media-libs/libpulse )
	quicktime? ( media-libs/libquicktime )
	sdl? ( media-libs/libsdl2[sound,joystick,vulkan?] )
	sndfile? ( media-libs/libsndfile )
	tbb? ( dev-cpp/tbb:= )
	usd? (
		<media-libs/openusd-25[monolithic,imaging,python,alembic?,draco?,embree?,materialx?,color-management?,openexr?,openimageio,openvdb?,osl?]
		>=media-libs/openusd-23.11[monolithic,imaging,python,alembic?,draco?,embree?,materialx?,color-management?,openexr?,openimageio,openvdb?,osl?]
	)
	valgrind? ( dev-util/valgrind )
	webp? ( >=media-libs/libwebp-1.3.2:= )
	wayland? (
		>=dev-libs/wayland-1.12
		>=dev-libs/wayland-protocols-1.32
		>=x11-libs/libxkbcommon-0.2.0
		dev-util/wayland-scanner
		>=gui-libs/libdecor-0.1.0
	)
	X? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
		virtual/glu
	)
	>=media-libs/mesa-23.3.0[X?,wayland?,llvm?,vulkan?]
	cg? ( media-blender/cg_preferences )
	|| (
		virtual/glu
		>=media-libs/glu-9.0.1
	)
	|| (
		virtual/jpeg:0=
		>=media-libs/libjpeg-turbo-2.1.3
	)
"

DEPEND="
	dev-cpp/eigen:=[cuda?]
	vulkan? (
		>=media-libs/shaderc-2022.3
		>=media-libs/vulkan-loader-1.3.268[X?,wayland?,layers]
	)
"

BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/setuptools-63.2.0[${PYTHON_USEDEP}]
		>=dev-python/cython-0.29.30[${PYTHON_USEDEP}]
		>=dev-python/autopep8-1.6.0[${PYTHON_USEDEP}]
		>=dev-python/pycodestyle-2.8.0[${PYTHON_USEDEP}]
	')
	>=dev-cpp/yaml-cpp-0.7.0
	>=dev-build/cmake-3.10
	>=dev-build/meson-0.63.0
	>=dev-util/vulkan-headers-1.3.268
	dev-util/patchelf
	virtual/pkgconfig
	lld? ( <sys-devel/lld-$((${LLVM_SLOT} + 1)):= )
	mold? ( sys-devel/mold:= )
	gold? ( <sys-devel/llvm-$((${LLVM_SLOT} + 1)):=[binutils-plugin] )
	llvm? (
		$(llvm_gen_dep '
			sys-devel/clang:${LLVM_SLOT}=
			sys-devel/llvm:${LLVM_SLOT}=
		')
	)
	doc? (
		>=dev-python/sphinx-3.3.1[latex]
		>=dev-python/sphinx_rtd_theme-0.5.0
		app-doc/doxygen[dot]
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	nls? ( sys-devel/gettext )
	wayland? (
		dev-util/wayland-scanner
	)
"

RESTRICT="
	mirror
	!test? ( test )
"

QA_EXECSTACK="usr/share/${PN}/${SLOT}/scripts/addons/cycles/lib/kernel_*"
QA_FLAGS_IGNORED="${QA_EXECSTACK}"
QA_PRESTRIPPED="${QA_EXECSTACK}"

PATCHES=(
	"${FILESDIR}/${PN}-3.0.0-boost_python.patch"
	"${FILESDIR}/${PN}-3.5.1-tbb-rpath.patch"
	"${FILESDIR}/${PN}-3.2.2-findtbb2.patch"
	"${FILESDIR}/x112.patch"
	"${FILESDIR}/${PN}-fix-desktop.patch"
	"${FILESDIR}/${PN}-fix-boost-1.81-iostream.patch"
)

blender_check_requirements() {
	[[ ${MERGE_TYPE} != binary ]] && ( use openmp && tc-check-openmp )

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

blender_get_version() {
	# Get blender version from blender itself.
	BV=$(grep "BLENDER_VERSION " source/blender/blenkernel/BKE_blender_version.h | cut -d " " -f 3; assert)
	if ((${BV:0:1} < 3)) ; then
		# Add period (290 -> 2.90).
		BV=${BV:0:1}.${BV:1}
	else
		# Add period and skip the middle number (301 -> 3.1)
		BV=${BV:0:1}.${BV:2}
	fi
}

pkg_pretend() {
	blender_check_requirements
}

pkg_setup() {
	python-single-r1_pkg_setup
	use llvm && llvm-r1_pkg_setup
}

src_unpack() {
	git-r3_src_unpack

	for repo in $(echo ${EGIT_REPO_URI_LIST}); do
		if [[ "${PV}" == "9999" ]]; then
			EGIT_BRANCH="main";
			EGIT_COMMIT=""
		else
			EGIT_BRANCH="blender-v${MY_PV}-release"
			#EGIT_COMMIT="v${PV}"
		fi
		EGIT_REPO_URI="${repo}"
		EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/scripts/$(echo -n "${repo}" | sed -rne 's/^http.*\/blender-([a-z-]*).*/\1/p')
		git-r3_src_unpack
	done
	if use test; then
		inherit subversion
		TESTS_SVN_URL=https://svn.blender.org/svnroot/bf-blender/trunk/lib/tests
		subversion_fetch ${TESTS_SVN_URL} ../lib/tests
		mkdir -p lib || die
		mv "${WORKDIR}"/blender-${TEST_TARBALL_VERSION}-tests/tests lib || die
	fi
	if use cg; then
		unset EGIT_BRANCH EGIT_COMMIT
		EGIT_CHECKOUT_DIR="${WORKDIR}"/cg_preferences/ \
		EGIT_REPO_URI="https://gitflic.ru/project/brothermechanic/cg_preferences.git" \
		git-r3_src_unpack
	fi
}

src_prepare() {
	cmake_src_prepare

	blender_get_version

	use cuda && cuda_src_prepare

	use portable || eapply "${FILESDIR}/${SLOT}"
	use optix && eapply "${FILESDIR}/blender-fix-optix-build.patch"
	use elibc_musl && eapply "${FILESDIR}/blender-4.0.0-support-building-with-musl-libc.patch"
	eapply "${FILESDIR}/blender-fix-lld-17-linking.patch"

	#no need `if use cg && [ -d ${CG_BLENDER_SCRIPTS_DIR} ]; then`
	#because CG_BLENDER_SCRIPTS_DIR set in cg/eclass/cg-blender-scripts-dir.eclass
	if use cg; then
		eapply "${WORKDIR}"/cg_preferences/patches/cg-defaults.patch
		cp "${WORKDIR}"/cg_preferences/share/startup.blend release/datafiles/ || die
		cp "${WORKDIR}"/cg_preferences/share/splash.png release/datafiles/ || die
		cp "${WORKDIR}"/cg_preferences/share/00_cg_preferences_service.py "${S}"/scripts/startup/ || die
		cp "${FILESDIR}"/99_cg_scripts_dir_service.py "${S}"/scripts/startup/ || die
		sed -i -e "s|cg_blender_scripts_dir =.*|cg_blender_scripts_dir = \"${CG_BLENDER_SCRIPTS_DIR}\"|" "${S}"/scripts/startup/99_cg_scripts_dir_service.py || die
		elog "Blender configured for CG overlay!"
	else
		ewarn "Blender is not configured for CG overlay!"
		ewarn "Please enable cg use flag for media-gfx/blender and"
		ewarn "set CG_BLENDER_SCRIPTS_DIR variable!"
	fi

	# remove some bundled deps
	use portable || rm -rf extern/{audaspace,json,Eigen3,lzo,gflags,glog,gtest,gmock,draco,ceres} || die

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
		-i doc/doxygen/Doxyfile || die

	# Prepare icons and .desktop files for slotting.
	sed \
		-e "s|blender.svg|blender-${SLOT}.svg|" \
		-e "s|blender-symbolic.svg|blender-${SLOT}-symbolic.svg|" \
		-e "s|blender.desktop|blender-${SLOT}.desktop|" \
		-i source/creator/CMakeLists.txt || die

	sed -e "s|Name=Blender|Name=Blender ${SLOT}|" -i release/freedesktop/blender.desktop || die
	sed -e "s|Exec.*|Exec=blender-${SLOT}|" -i release/freedesktop/blender.desktop || die
	sed -e "s|Icon=blender|Icon=blender-${SLOT}|" -i release/freedesktop/blender.desktop || die

#   echo -e " #define BUILD_HASH \"$(git-r3_peek_remote_ref ${EGIT_REPO_URI_LIST% *})\"\n" \
#		"#define BUILD_COMMIT_TIMESTAMP \"\"\n" \
#  		"#define BUILD_BRANCH \"${EGIT_BRANCH} modified\"\n" \
#		"#define BUILD_DATE \"$(TZ=\"UTC\" date --date=today +%Y-%m-%d)\"\n" \
#		"#define BUILD_TIME \"$(TZ=\"UTC\" date --date=today +%H:%M:%S)\"\n" \
#		"#include \"buildinfo_static.h\"\n" > build_files/cmake/buildinfo.h || die

	mv release/freedesktop/icons/scalable/apps/blender.svg release/freedesktop/icons/scalable/apps/blender-${SLOT}.svg || die
	mv release/freedesktop/icons/symbolic/apps/blender-symbolic.svg release/freedesktop/icons/symbolic/apps/blender-${SLOT}-symbolic.svg || die
	mv release/freedesktop/blender.desktop release/freedesktop/blender-${SLOT}.desktop || die

	if use test; then
		# Without this the tests will try to use /usr/bin/blender and /usr/share/blender/ to run the tests.
		sed -e "s|set(TEST_INSTALL_DIR.*|set(TEST_INSTALL_DIR ${T}/usr)|g" -i tests/CMakeLists.txt || die
		sed -e "s|string(REPLACE.*|set(TEST_INSTALL_DIR ${T}/usr)|g" -i build_files/cmake/Modules/GTestTesting.cmake || die
	fi

	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"

	# linguas cleanup
	local i
	if ! use nls; then
		rm -r "${S}"/release/datafiles/locale || die
	else
		pushd "${S}"/locale/po
		for i in *.po ; do
			mylang=${i%.po}
			use l10n_${mylang} || { rm -r ${i} || die ; }
		done
		popd
	fi
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-cppflags -funsigned-char -fno-strict-aliasing
	append-lfs-flags

	local mycmakeargs=()

	use openvdb && openvdb_src_configure
	# CUDA Kernel Selection
	if use cuda; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT};"
		done

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_TARGETS}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_BINARIES_ARCH=${CUDA_TARGETS%%*;}
			)
		fi
	fi

	mycmakeargs+=(
		-DSUPPORT_NEON_BUILD=$(usex cpu_flags_arm_neon)
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DWITH_CPU_SIMD=$(usex simd)
		-DWITH_PYTHON_INSTALL=$(usex portable)					# Copy system python
		-DWITH_PYTHON_INSTALL_NUMPY=$(usex portable)
		-DWITH_PYTHON_INSTALL_ZSTANDARD=$(usex portable)
		-DWITH_PYTHON_MODULE=$(usex headless)					# build as regular python module
		-DWITH_HEADLESS=$(usex headless)						# server mode only
		-DWITH_ALEMBIC=$(usex alembic)							# export format support
		-DWITH_ASSERT_ABORT=$(usex debug)
		-DWITH_BOOST=$(usex boost)
		-DWITH_BOOST_ICU=$(usex icu)
		-DWITH_BULLET=$(usex bullet)							# Physics Engine
		-DWITH_SYSTEM_BULLET=no									# currently unsupported
		-DWITH_CODEC_AVI=$(usex avi)
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg)
		-DWITH_CODEC_SNDFILE=$(usex sndfile)
		-DWITH_CYCLES=$(usex cycles)							# Enable Cycles Render Engine
		-DWITH_CUDA=$(usex cuda)
		-DWITH_CYCLES_DEVICE_CUDA=$(usex cuda)
		-DWITH_CYCLES_DEVICE_OPTIX=$(usex optix)
		-DWITH_CYCLES_DEVICE_HIP=$(usex rocm)
		-DWITH_CYCLES_HIP_BINARIES=$(usex cycles-bin-kernels $(usex rocm) no)
		-DWITH_HIP_DYNLOAD=$(usex rocm $(usex cycles-bin-kernels no yes) no)
		-DWITH_CYCLES_CUDA_BINARIES=$(usex cycles-bin-kernels $(usex cuda) no)	# build cuda kernels now, not in runtime
		-DWITH_CYCLES_CUDA_BUILD_SERIAL=$(usex cuda)			# Build cuda kernels in serial mode (if parallel build takes too much RAM or crash)
		-DWITH_CUDA_DYNLOAD=$(usex cuda $(usex cycles-bin-kernels no yes) no)
		-DWITH_CYCLES_DEVICE_ONEAPI=$(usex oneapi)
		-DWITH_CYCLES_ONEAPI_BINARIES=$(usex cycles-bin-kernels $(usex oneapi) no)
		-DWITH_CYCLES_EMBREE=$(usex embree)						# Speedup library for Cycles
		-DWITH_CYCLES_NATIVE_ONLY=$(usex cycles)				# for native kernel only
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_PATH_GUIDING=$(usex openpgl)				# Speedup library for Cycles
		-DWITH_CYCLES_STANDALONE=no
		-DWITH_CYCLES_STANDALONE_GUI=no
		-DWITH_CYCLES_DEBUG=$(usex debug)
		-DWITH_CYCLES_LOGGING=yes
		#-DWITH_CYCLES_NETWORK=no
		-DWITH_DOC_MANPAGE=$(usex man)
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_FREESTYLE=$(usex freestyle)						# advanced edges rendering
		-DWITH_SYSTEM_FREETYPE=$(usex !portable)
		-DWITH_GHOST_X11=$(usex X)								# Enable building against X11
		-DWITH_GHOST_XDND=$(usex X)								# drag-n-drop support on X11
		-DWITH_GHOST_WAYLAND=$(usex wayland)					# Enable building against wayland
		-DWITH_GHOST_WAYLAND_APP_ID=blender-${BV}
		-DWITH_GHOST_WAYLAND_DBUS=$(usex wayland)
		-DWITH_GHOST_WAYLAND_DYNLOAD=$(usex wayland)
		-DWITH_GHOST_WAYLAND_LIBDECOR=$(usex wayland)
		-DWITH_GMP=$(usex gmp)									# boolean engine
		-DWITH_HARU=$(usex pdf)									# export format support
		-DWITH_IO_GPENCIL=$(usex pdf)							# export format support
		-DWITH_INSTALL_PORTABLE=$(usex portable)
		-DWITH_CPU_CHECK=$(usex portable)
		-DWITH_IMAGE_CINEON=$(usex dpx)
		-DWITH_IMAGE_OPENEXR=$(usex openexr)
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k)
		-DWITH_IMAGE_WEBP=$(usex webp)
		-DWITH_INPUT_NDOF=$(usex ndof)
		-DWITH_INPUT_IME=no
		-DWITH_IK_SOLVER=no 									# Disable legacy IK solver
		-DWITH_IK_ITASC=yes
		-DWITH_INTERNATIONAL=$(usex nls)						# I18N fonts and text
		-DWITH_JACK=$(usex jack)
		-DWITH_JACK_DYNLOAD=$(usex jack)
		-DWITH_PULSEAUDIO=$(usex pulseaudio)
		-DWITH_PULSEAUDIO_DYNLOAD=$(usex pulseaudio)
		-DWITH_LZMA=$(usex lzma)								# used for pointcache only
		-DWITH_LZO=$(usex lzo)									# used for pointcache only
		-DWITH_LLVM=$(usex llvm)
		-DWITH_CLANG=$(usex llvm)
		-DWITH_LIBMV=$(usex libmv)                           	# Enable libmv sfm camera tracking
		-DWITH_MEM_JEMALLOC=$(usex jemalloc)					# Enable malloc replacement
		-DWITH_MEM_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex fluid)							# Mantaflow Fluid Simulation Framework
		-DWITH_MOD_REMESH=$(usex remesh)						# Remesh Modifier
		-DWITH_MOD_OCEANSIM=$(usex oceansim)					# Ocean Modifier
		-DWITH_NANOVDB=$(usex nanovdb)							# OpenVDB for rendering on the GPU
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)						# export format support
		-DWITH_IO_WAVEFRONT_OBJ=$(usex obj)						# export format support
		-DWITH_IO_PLY=$(usex ply)								# export format support
		-DWITH_IO_STL=$(usex stl)								# export format support
		-DWITH_OPENCOLORIO=$(usex color-management)
		-DWITH_OPENIMAGEDENOISE=$(usex oidn)					# compositing node
		-DWITH_OPENMP=$(usex openmp)
		-DWITH_OPENSUBDIV=$(usex opensubdiv)					# for surface subdivision
		-DWITH_OPENVDB=$(usex openvdb)							# advanced remesh and smoke
		-DWITH_OPENVDB_BLOSC=$(usex openvdb)					# compression for OpenVDB
		-DWITH_QUADRIFLOW=$(usex quadriflow)					# remesher
		-DWITH_SDL=$(usex sdl)									# for sound and joystick support
		-DWITH_STATIC_LIBS=$(usex portable)
		-DWITH_DRACO=$(usex draco)
		-DWITH_SYSTEM_DRACO=$(usex !portable)
		-DWITH_AUDASPACE=yes
		-DWITH_SYSTEM_AUDASPACE=$(usex !portable)
		-DWITH_SYSTEM_EIGEN3=$(usex !portable)
		-DWITH_SYSTEM_LZO=$(usex !portable)
		-DWITH_SYSTEM_GFLAGS=$(usex !portable)
		-DWITH_SYSTEM_GLOG=$(usex !portable)
		-DWITH_SYSTEM_CERES=$(usex !portable)
		-DCERES_INCLUDE_DIRS="/usr/include/ceres"
		-DWITH_GTESTS=$(usex gtests)
		-DWITH_SYSTEM_GTESTS=$(usex !portable)
		-DWITH_GHOST_DEBUG=$(usex debug)
		-DWITH_CXX_GUARDEDALLOC=$(usex debug)
		-DWITH_TBB=$(usex tbb)
		-DWITH_USD=$(usex usd)									# export format support
		-DWITH_VULKAN_BACKEND=$(usex vulkan)
		-DWITH_VULKAN_GUARDEDALLOC=$(usex vulkan)
		-DWITH_XR_OPENXR=$(usex openxr)							# VR interface
		#-DSYCL_LIBRARY="/usr/lib/llvm/intel"
		#-DSYCL_INCLUDE_DIR="/usr/lib/llvm/intel/include"
		#-DLLVM_LIBRARY="/usr/lib/llvm/${LLVM_SLOT}/lib64/libLLVM.so"
		-DUSD_ROOT_DIR="${ESYSROOT}/usr/$(get_libdir)/openusd/lib"
		-DMaterialX_DIR="${ESYSROOT}/usr/$(get_libdir)/cmake/MaterialX"
		-DWITH_NINJA_POOL_JOBS=no								# for machines with 16GB of RAM or less
		-DBUILD_SHARED_LIBS=no
		#-DWITH_EXPERIMENTAL_FEATURES=yes
		-Wno-dev
		#-DCMAKE_FIND_DEBUG_MODE=yes
		-DWITH_STRICT_BUILD_OPTIONS=yes
		-DWITH_LIBS_PRECOMPILED=no
		-DWITH_BUILDINFO=yes
		-DWITH_UNITY_BUILD=no 									# Enable Unity build for blender modules (memory usage/compile time)
		-DWITH_HYDRA=no 										# MacOS features enabled by default if WITH_STRICT_BUILD_OPTIONS=yes
		-DWITH_MATERIALX=$(usex materialx)
		-DHIP_HIPCC_FLAGS="-fcf-protection=none"
	)

	if use optix; then
		mycmakeargs+=(
			-DCYCLES_RUNTIME_OPTIX_ROOT_DIR="${EPREFIX}"/opt/optix
			-DOPTIX_ROOT_DIR="${EPREFIX}"/opt/optix
		)
	fi

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use arm64 && append-flags -flax-vector-conversions

	append-cppflags $(usex debug '-DDEBUG' '-DNDEBUG')

	if tc-is-gcc ; then
		# These options only exist when GCC is detected.
		mycmakeargs+=(
			-DWITH_LINKER_LLD=$(usex lld)
			-DWITH_LINKER_GOLD=$(usex gold)
			-DWITH_LINKER_MOLD=$(usex mold)
		)
	fi

	if use test ; then
		local CYCLES_TEST_DEVICES=( "CPU" )
		if use cycles-bin-kernels; then
			use cuda && CYCLES_TEST_DEVICES+=( "CUDA" )
			use optix && CYCLES_TEST_DEVICES+=( "OPTIX" )
			use hip && CYCLES_TEST_DEVICES+=( "HIP" )
		fi
		mycmakeargs+=(
			-DCYCLES_TEST_DEVICES:STRING="$(local IFS=";"; echo "${CYCLES_TEST_DEVICES[*]}")"
			-DWITH_COMPOSITOR_REALTIME_TESTS=yes
			-DWITH_OPENGL_DRAW_TESTS=yes
			-DWITH_OPENGL_RENDER_TESTS=yes
		)
	fi

	cmake_src_configure
}

src_test() {
	# A lot of tests needs to have access to the installed data files.
	# So install them into the image directory now.
	DESTDIR="${T}" cmake_build install "$@"

	blender_get_version
	# Define custom blender data/script file paths not be able to find them otherwise during testing.
	# (Because the data is in the image directory and it will default to look in /usr/share)
	export BLENDER_SYSTEM_SCRIPTS="${ED}"/usr/share/blender/${SLOT}/scripts
	export BLENDER_SYSTEM_DATAFILES="${ED}"/usr/share/blender/${SLOT}/datafiles

	# Sanity check that the script and datafile path is valid.
	# If they are not vaild, blender will fallback to the default path which is not what we want.
	[ -d "$BLENDER_SYSTEM_SCRIPTS" ] || die "The custom script path is invalid, fix the ebuild!"
	[ -d "$BLENDER_SYSTEM_DATAFILES" ] || die "The custom datafiles path is invalid, fix the ebuild!"

	cmake_src_test

	# Clean up the image directory for src_install
	rm -fr "${T}"/usr || die
}

src_install() {
	blender_get_version

	# Pax mark blender for hardened support.
	pax-mark m "${BUILD_DIR}"/bin/blender

	cmake_src_install

	if use man; then
		# Slot the man page
		mv "${ED}/usr/share/man/man1/blender.1" "${ED}/usr/share/man/man1/blender-${BV}.1" || die
	fi

	if use doc; then
		# Define custom blender data/script file paths. Otherwise Blender will not be able to find them during doc building.
		# (Because the data is in the image directory and it will default to look in /usr/share)
		export BLENDER_SYSTEM_SCRIPTS=${ED}/usr/share/blender/${SLOT}/scripts
		export BLENDER_SYSTEM_DATAFILES=${ED}/usr/share/blender/${SLOT}/datafiles

		# Workaround for binary drivers.
		addpredict /dev/ati
		addpredict /dev/dri
		addpredict /dev/nvidiactl

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "sphinx failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."

		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/.

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/.
	fi

	# Fix doc installdir
	docinto html
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender*
	python_optimize "${ED%/}/usr/share/blender/${SLOT}/scripts"

	use portable && dodir "${ED%/}"/usr/bin
	pushd ${ED}/usr/bin
		mv "blender-thumbnailer" "blender-${SLOT}-thumbnailer" || die
		ln -s "blender-${SLOT}-thumbnailer" "blender-thumbnailer"
		mv "blender" "blender-${SLOT}" || die
		ln -s "blender-${SLOT}" "blender"
	popd

	elog "${PN^}-$( grep -Po 'CPACK_PACKAGE_VERSION "\K[^"]..' ${BUILD_DIR}/CPackConfig.cmake ) has been installed."
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherent risks with running unknown python scripts."
	elog
	elog "There is some my prefer blender settings as patches"
	elog "find them in cg/local-patches/blender/"
	elog "To apply someone copy them in "
	elog "/etc/portage/patches/media-gfx/blender/"
	elog "or create symlink"
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "changing the 'Temporary Files' directory in Blender preferences."
	elog

	if use osl; then
		ewarn ""
		ewarn "OSL is know to cause runtime segfaults if Mesa has been linked to"
		ewarn "an other LLVM version than what OSL is linked to."
		ewarn "See https://bugs.gentoo.org/880671 for more details"
		ewarn ""
	fi

	if ! use python_single_target_python3_12; then
		elog "You are building Blender with a newer python version than"
		elog "supported by this version upstream."
		elog "If you experience breakages with e.g. plugins, please switch to"
		elog "python_single_target_python3_11 instead."
		elog
	fi

	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update
}

pkg_postrm() {
	xdg_icon_cache_update
	xdg_mimeinfo_database_update
	xdg_desktop_database_update

	ewarn ""
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${SLOT}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn ""
}
