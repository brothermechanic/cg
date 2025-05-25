# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
OPENVDB_COMPAT=( {7..12} )
LLVM_COMPAT=( {18..19} )
LLVM_OPTIONAL=1

ROCM_SKIP_GLOBALS=1

inherit cuda rocm llvm-r1
inherit eapi9-pipestatus check-reqs flag-o-matic pax-utils python-single-r1 toolchain-funcs virtualx openvdb cg-blender-scripts-dir
inherit cmake xdg-utils git-r3

DESCRIPTION="Blender is a free and open-source 3D creation suite."
HOMEPAGE="https://www.blender.org"

EGIT_REPO_URI="https://projects.blender.org/blender/blender.git https://github.com/blender/blender.git"
EGIT_SUBMODULES=( '*' '-lib/*' '-tools/*' '-release/datafiles/assets' )
EGIT_LFS="yes"
if [[ ${PV} == 9999 ]]; then
	EGIT_BRANCH="main"
	#EGIT_COMMIT="0f3fdd25bcabac1d68d02fb246d961ea56fe49a1"
	EGIT_CLONE_TYPE="shallow"
	MY_PV="4.5"
	KEYWORDS=""
else
	MY_PV="$(ver_cut 1-2)"
	EGIT_BRANCH="blender-v${MY_PV}-release"
	#EGIT_COMMIT="v${PV}"
	KEYWORDS="~amd64 ~arm ~arm64"
fi

[[ "4.0 3.6" =~ "${MY_PV}"  ]] && OSL_PV="13" || OSL_PV="14"
[[ "4.0 3.6 4.2 4.3 4.4" =~ "${MY_PV}" ]] && AUD_PV="1.5.1" || AUD_PV="1.6.1"

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
	gfx1036
	gfx1100
	gfx1101
	gfx1102
	gfx1103
	gfx1150
	gfx1151
)

IUSE_CPU="+simd +tbb -lld -gold +mold -cpu_flags_arm_neon llvm +openmp -valgrind +jemalloc"
IUSE_GPU="cuda optix hip oneapi -cycles-bin-kernels ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_} ${AMDGPU_TARGETS_COMPAT[@]/#/amdgpu_targets_} vulkan"
IUSE_DESKTOP="+cg -portable +X headless +nls icu -ndof wayland gnome"
IUSE_LIBS="+bullet +boost +draco +manifold +materialx +color-management +oidn +opensubdiv +openvdb nanovdb openxr +libmv lzma lzo osl +fftw +potrace +pugixml +otf"
IUSE_MOD="+fluid +smoke +oceansim +remesh +gmp +quadriflow +addons +addons-contrib +assets"
IUSE_RENDER="+cycles +openpgl +embree +freestyle"
IUSE_3DFILES="-alembic usd +collada +obj +ply +stl"
IUSE_IMAGE="-dpx +openexr jpeg2k webp +pdf"
IUSE_CODEC="avi +ffmpeg flac -sndfile +quicktime aom lame opus theora vorbis vpx x264 xvid"
IUSE_SOUND="jack openal -pulseaudio sdl"
IUSE_TEST="-debug -doc -man -gtests renderdoc -test -experimental"

IUSE="${IUSE_CPU} ${IUSE_GPU} ${IUSE_DESKTOP} ${IUSE_LIBS} ${IUSE_MOD} ${IUSE_RENDER} ${IUSE_3DFILES} ${IUSE_IMAGE} ${IUSE_CODEC} ${IUSE_SOUND} ${IUSE_TEST}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	^^ ( gold lld mold )
	|| ( wayland X )
	!boost? ( !alembic !color-management !cycles !nls !openvdb )
	alembic? ( openexr )
	cycles? ( openexr tbb )
	embree? ( cycles tbb )
	smoke? ( fftw )
	cuda? ( cycles )
	optix? ( cuda )
	fluid? ( fftw tbb )
	nanovdb? ( cuda )
	oceansim? ( fftw )
	oidn? ( cycles tbb )
	oneapi? ( cycles )
	optix? ( cycles )
	openvdb? ( ${OPENVDB_REQUIRED_USE} cycles tbb )
	opensubdiv? ( X )
	osl? ( cycles llvm pugixml )
	hip? ( cycles llvm )
	vulkan? ( llvm )
	test? ( gtests color-management )
	usd? ( tbb )
"

LANGS="en en_GB ab ar be bg ca cs da de el eo es es_ES eu fa fi fr ha he hi hr hu id it ja ka km ko ky lt ne nl pl pt_BR pt ro ru sl sk sr@latin sr sv sw ta th tr zh_TW uk ur vi zh_CN zh_HANS zh_HANT"

for X in ${LANGS} ; do
	IUSE+=" l10n_${X}"
	REQUIRED_USE+=" l10n_${X}? ( nls )"
done

CODECS="
	aom? (
		>=media-libs/libaom-3.3.0
	)
	lame? (
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
		dev-libs/boost[nls?,icu?,threads(+),python,numpy,${PYTHON_USEDEP}]
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
	dev-cpp/gflags:=
	media-libs/freetype:=[brotli,bzip2,png]
	media-libs/libepoxy:=
	>=dev-cpp/pystring-1.1.3:=
	>=dev-libs/fribidi-1.0.12:=
	>=sys-libs/minizip-ng-3.0.7
	>=media-libs/tiff-4.6.0
	>=sys-libs/zlib-1.2.13
	dev-libs/lzo:2
	media-libs/libglvnd
	>=media-libs/libpng-1.6.37:0=
	media-libs/libsamplerate
	virtual/libintl
	alembic? ( >=media-gfx/alembic-1.8.3-r2[boost(+),hdf(+)] )
	collada? ( >=media-libs/opencollada-1.6.68 )
	cuda? ( dev-util/nvidia-cuda-toolkit:= )
	draco? ( >=media-libs/draco-1.5.2:= )
	embree? (
		>=media-libs/embree-4.3.2[raymask,tbb?]
		<media-libs/embree-5
	)
	ffmpeg? (
		<media-video/ffmpeg-8:=[jpeg2k?,opus?,lame?,sdl,theora?,vorbis?,vpx?,x264?,xvid?,zlib]
		>media-video/ffmpeg-5:=[jpeg2k?,opus?,lame?,sdl,theora?,vorbis?,vpx?,x264?,xvid?,zlib]
	)
	fftw? ( sci-libs/fftw:3.0=[threads] )
	flac? (	>=media-libs/flac-1.4.2	)
	gmp? ( >=dev-libs/gmp-6.2.1[cxx] )
	hip? (
		>=dev-util/hip-6.1:=
	)
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
		app-misc/spacenavd
		>=dev-libs/libspnav-1.1
	)
	manifold? (
		>=sci-mathematics/manifold-1.3.1:=
	)
	materialx? (
		>=media-libs/materialx-1.38.8[${PYTHON_SINGLE_USEDEP},python]
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.23.1 )
	<=media-libs/audaspace-${AUD_PV}:=[python,openal?,sdl?,pulseaudio?]
	oneapi? ( dev-libs/intel-compute-runtime[l0] )
	media-libs/glew:*
	oidn? ( >=media-libs/oidn-2.1.0[cuda?] )
	<media-libs/openimageio-3.1[${PYTHON_SINGLE_USEDEP},${OPENVDB_SINGLE_USEDEP},python,color-management?]
	>=media-libs/openimageio-2.5.11.0[${PYTHON_SINGLE_USEDEP},${OPENVDB_SINGLE_USEDEP},python,color-management?]
	>=dev-cpp/robin-map-0.6.2
	>=dev-libs/libfmt-9.1.0
	color-management? ( >=media-libs/opencolorio-2.3.0:= )
	openexr? ( >=media-libs/openexr-3.2.1:= )
	openpgl? (
		<media-libs/openpgl-0.9[tbb?]
		>=media-libs/openpgl-0.5[tbb?]
	)
	opensubdiv? ( >=media-libs/opensubdiv-3.6.0[cuda?,tbb?,opengl] )
	openvdb? (
		>=media-gfx/openvdb-11.0.0:=[${OPENVDB_SINGLE_USEDEP},cuda?,nanovdb?]
		<media-gfx/openvdb-13.0.0:=[${OPENVDB_SINGLE_USEDEP},cuda?,nanovdb?]
		>=dev-libs/c-blosc-1.21.1[zlib]
	)
	openxr? (
		>=media-libs/openxr-1.0.17
	)
	optix? ( <dev-libs/optix-10:= )
	osl? (
		>=media-libs/osl-1.${OSL_PV}:=[optix?]
		<media-libs/osl-1.$((${OSL_PV}+1)):=[optix?]
		media-libs/mesa[${LLVM_USEDEP}]
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
		<media-libs/openusd-26[${PYTHON_SINGLE_USEDEP},monolithic,imaging,python,alembic?,draco?,embree?,materialx?,color-management?,openexr?,openimageio,openvdb?,osl?]
		>=media-libs/openusd-25[${PYTHON_SINGLE_USEDEP},monolithic,imaging,python,alembic?,draco?,embree?,materialx?,color-management?,openexr?,openimageio,openvdb?,osl?]
	)
	valgrind? ( dev-debug/valgrind )
	webp? ( >=media-libs/libwebp-1.3.2:= )
	wayland? (
		>=dev-libs/wayland-1.23
		>=dev-libs/wayland-protocols-1.36
		>=x11-libs/libxkbcommon-0.2.0
		dev-util/wayland-scanner
		gnome? ( gui-libs/libdecor[gtk,dbus] )
	)
	vulkan? (
		media-libs/shaderc
		dev-util/spirv-tools
		dev-util/glslang
		media-libs/vulkan-loader
	)
	otf? (
		media-libs/harfbuzz
	)
	renderdoc? (
		media-gfx/renderdoc
	)
	X? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
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
	dev-vcs/git
	dev-util/patchelf
	virtual/pkgconfig
	dev-vcs/git-lfs
	mold? ( sys-devel/mold:= )
	$(llvm_gen_dep '
		lld? ( llvm-core/lld:${LLVM_SLOT}= )
		gold? ( llvm-core/llvm:${LLVM_SLOT}=[binutils-plugin] )
		llvm? (
			llvm-core/clang:${LLVM_SLOT}=
			llvm-core/llvm:${LLVM_SLOT}=
		)
	')
	doc? (
		app-text/doxygen[dot]
		dev-python/sphinx[latex]
		dev-python/sphinx_rtd_theme
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
	vulkan? (
		dev-util/spirv-headers
		dev-util/vulkan-headers
	)
	nls? ( sys-devel/gettext )
	wayland? (
		dev-util/wayland-scanner
	)
	X? (
		x11-base/xorg-proto
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
	"${FILESDIR}/x112.patch"
	"${FILESDIR}/${PN}-4.1.1-FindLLVM.patch"
	"${FILESDIR}/${PN}-4.4.0-optix-compile-flags.patch"
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

	if use oneapi; then
		einfo "The Intel oneAPI support is rudimentary."
		einfo ""
		einfo "Please report any bugs you find to https://bugs.gentoo.org/"
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
	use llvm && llvm-r1_pkg_setup
}

src_unpack() {
	if ! use test; then
		EGIT_SUBMODULES+=( '-tests/*' )
	fi
	git-r3_src_unpack

	if use addons; then
		if [[ "3.6 4.1" =~ "${MY_PV}" ]]; then
			EGIT_BRANCH="blender-v${MY_PV}-release"
			#EGIT_COMMIT="v${PV}"
		else
			EGIT_BRANCH="main"
			EGIT_COMMIT=""
			EGIT_CLONE_TYPE="shallow"
		fi
		EGIT_LFS="yes"
		EGIT_REPO_URI="https://projects.blender.org/blender/blender-addons.git https://github.com/blender/blender-addons"
		EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/scripts/blender-addons
		git-r3_src_unpack
	fi

	if use addons-contrib; then
		if [[ "3.6 4.1" =~ "${MY_PV}" ]]; then
			EGIT_BRANCH="blender-v${MY_PV}-release"
			#EGIT_COMMIT="v${PV}"
		else
			EGIT_BRANCH="main"
			EGIT_COMMIT=""
			EGIT_CLONE_TYPE="shallow"
		fi
		EGIT_LFS="yes"
		EGIT_REPO_URI="https://projects.blender.org/blender/blender-addons-contrib.git https://github.com/blender/blender-addons-contrib"
		EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/scripts/blender-addons-contrib
		git-r3_src_unpack
	fi

	if use assets; then
		if [[ "4.2 4.3 4.4" =~ "${MY_PV}" ]]; then
			EGIT_LFS="yes"
			EGIT_BRANCH="blender-v${MY_PV}-release"
			EGIT_REPO_URI="https://projects.blender.org/blender/blender-assets.git"
			#EGIT_COMMIT="v${PV}"
			EGIT_CHECKOUT_DIR=${WORKDIR}/${P}/release/datafiles/assets
			git-r3_src_unpack
		fi
	fi

	if use cg; then
		unset EGIT_BRANCH EGIT_COMMIT
		EGIT_CHECKOUT_DIR="${WORKDIR}"/cg_preferences/ \
		EGIT_REPO_URI="https://gitflic.ru/project/brothermechanic/cg_preferences.git" \
		git-r3_src_unpack
	fi
}

src_prepare() {
	use cuda && cuda_src_prepare

	cmake_src_prepare

	blender_get_version

	use portable || eapply "${FILESDIR}/${SLOT}"
	use optix && eapply "${FILESDIR}/blender-fix-optix-build.patch"
	#use elibc_musl && append-cflags "-D_GNU_SOURCE"
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
		-e "s|org.blender.Blender.metainfo.xml|blender-${BV}.metainfo.xml|" \
		-i source/creator/CMakeLists.txt || die

	sed \
		-e "s|Name=Blender|Name=Blender ${SLOT}|" \
		-e "s|Exec.*|Exec=blender-${SLOT}|" \
		-e "s|Icon=blender|Icon=blender-${SLOT}|" \
		-i release/freedesktop/blender.desktop || die

	sed \
		-e "/CMAKE_INSTALL_PREFIX_WITH_CONFIG/{s|\${CMAKE_INSTALL_PREFIX}|${T}\${CMAKE_INSTALL_PREFIX}|g}" \
		-i CMakeLists.txt \
		|| die CMAKE_INSTALL_PREFIX_WITH_CONFIG
#   echo -e " #define BUILD_HASH \"$(git-r3_peek_remote_ref ${EGIT_REPO_URI_LIST% *})\"\n" \
#		"#define BUILD_COMMIT_TIMESTAMP \"\"\n" \
#  		"#define BUILD_BRANCH \"${EGIT_BRANCH} modified\"\n" \
#		"#define BUILD_DATE \"$(TZ=\"UTC\" date --date=today +%Y-%m-%d)\"\n" \
#		"#define BUILD_TIME \"$(TZ=\"UTC\" date --date=today +%H:%M:%S)\"\n" \
#		"#include \"buildinfo_static.h\"\n" > build_files/cmake/buildinfo.h || die

	mv \
		"release/freedesktop/icons/scalable/apps/blender.svg" \
		"release/freedesktop/icons/scalable/apps/blender-${SLOT}.svg" \
		|| die
	mv \
		"release/freedesktop/icons/symbolic/apps/blender-symbolic.svg" \
		"release/freedesktop/icons/symbolic/apps/blender-${SLOT}-symbolic.svg" \
		|| die
	mv \
		"release/freedesktop/blender.desktop" \
		"release/freedesktop/blender-${SLOT}.desktop" \
		|| die

	mv \
		"release/freedesktop/org.blender.Blender.metainfo.xml" \
		"release/freedesktop/blender-${SLOT}.metainfo.xml" \
		|| die

	sed \
		-e "s#\(set(cycles_kernel_runtime_lib_target_path \)\${cycles_kernel_runtime_lib_target_path}\(/lib)\)#\1\${CYCLES_INSTALL_PATH}\2#" \
		-i intern/cycles/kernel/CMakeLists.txt \
		|| die

	if use hip; then
		# fix hardcoded path
		sed \
			-e "s#opt/rocm/hip/bin#$(hipconfig -p)/bin#g" \
			-i extern/hipew/src/hipew.c \
			|| die
	fi

	if use test; then
		# Without this the tests will try to use /usr/bin/blender and /usr/share/blender/ to run the tests.
		sed \
			-e "/string(REPLACE.*TEST_INSTALL_DIR/{s|\${CMAKE_INSTALL_PREFIX}|${T}\${CMAKE_INSTALL_PREFIX}|g}" \
			-i "build_files/cmake/testing.cmake" \
			|| die "REPLACE.*TEST_INSTALL_DIR"

		# assertEquals was deprecated in Python-3.2 use assertEqual instead
		sed \
			-e 's/assertEquals/assertEqual/g' \
			-i tests/python/bl_animation_action.py \
			|| die

		sed -e '1i #include <cstdint>' -i extern/gtest/src/gtest-death-test.cc || die
	else
		cmake_comment_add_subdirectory tests
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

	# Workaround for bug #922600
	append-ldflags "$(test-flags-CCLD -Wl,--undefined-version)"

	append-lfs-flags

	local mycmakeargs=()

	use openvdb && openvdb_src_configure

	mycmakeargs+=(
		-DSUPPORT_NEON_BUILD=$(usex cpu_flags_arm_neon)
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DWITH_PYTHON_NUMPY=yes
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
		-DWITH_CYCLES_DEVICE_HIP=$(usex hip)
		-DWITH_CYCLES_DEVICE_HIPRT=$(usex hip)
		-DWITH_CYCLES_HIP_BINARIES=$(usex hip $(usex cycles-bin-kernels) no)
		-DWITH_HIP_DYNLOAD=$(usex hip $(usex cycles-bin-kernels no yes) no)
		-DWITH_CYCLES_CUDA_BINARIES=$(usex cuda $(usex cycles-bin-kernels) no)	# build cuda kernels now, not in runtime
		-DWITH_CYCLES_CUDA_BUILD_SERIAL=$(usex cuda)			# Build cuda kernels in serial mode (if parallel build takes too much RAM or crash)
		-DWITH_CUDA_DYNLOAD=$(usex cuda $(usex cycles-bin-kernels no yes) no)
		-DWITH_CYCLES_DEVICE_ONEAPI=$(usex oneapi)
		-DWITH_CYCLES_ONEAPI_BINARIES=$(usex oneapi $(usex cycles-bin-kernels) no)
		-DWITH_CYCLES_HYDRA_RENDER_DELEGATE="no"                # TODO: package Hydra
		-DWITH_CYCLES_EMBREE=$(usex embree)						# Speedup library for Cycles
		-DWITH_CYCLES_NATIVE_ONLY=$(usex cycles)				# for native kernel only
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_PATH_GUIDING=$(usex openpgl)				# Speedup library for Cycles
		-DWITH_CYCLES_STANDALONE=no
		-DWITH_CYCLES_STANDALONE_GUI=no
		-DWITH_CYCLES_DEBUG=$(usex debug)
		-DWITH_CYCLES_LOGGING=yes
		#-DWITH_CYCLES_NETWORK=no
		-DWITH_BLENDER_THUMBNAILER="yes"
		-DWITH_DOC_MANPAGE=$(usex man)
		-DWITH_RENDERDOC="$(usex renderdoc)"
		-DWITH_EXPERIMENTAL_FEATURES="$(usex experimental)"
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_FREESTYLE=$(usex freestyle)						# advanced edges rendering
		-DWITH_HARFBUZZ="$(usex otf)"
		-DWITH_SYSTEM_FREETYPE=$(usex !portable)
		-DWITH_GHOST_X11=$(usex X)								# Enable building against X11
		-DWITH_GHOST_XDND=$(usex X)								# drag-n-drop support on X11
		-DWITH_GHOST_WAYLAND=$(usex wayland)					# Enable building against wayland
		-DWITH_GHOST_WAYLAND_DYNLOAD=$(usex wayland)
		-DWITH_GHOST_WAYLAND_APP_ID=blender-${BV}
		-DWITH_GHOST_WAYLAND_LIBDECOR=$(usex gnome)
		-DWITH_GHOST_SDL=$(usex sdl)
		-DWITH_GMP=$(usex gmp)									# boolean engine
		-DWITH_HARU=$(usex pdf)									# export format support
		-DWITH_IO_GREASE_PENCIL=$(usex pdf) 				    # export format support
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
		#-DWITH_CXX_GUARDEDALLOC=$(usex debug)
		-DWITH_PUGIXML=$(usex pugixml)
		-DWITH_POTRACE=$(usex potrace)
		-DWITH_TBB=$(usex tbb)
		-DWITH_USD=$(usex usd)									# export format support
		-DWITH_VULKAN_BACKEND=$(usex vulkan)
		#-DWITH_VULKAN_GUARDEDALLOC=$(usex vulkan)
		-DWITH_XR_OPENXR=$(usex openxr)							# VR interface
		#-DSYCL_LIBRARY="/usr/lib/llvm/intel"
		#-DSYCL_INCLUDE_DIR="/usr/lib/llvm/intel/include"
		-DUSD_ROOT_DIR="${ESYSROOT}/usr/$(get_libdir)/openusd/lib"
		#-DMaterialX_DIR="${ESYSROOT}/usr/$(get_libdir)/cmake/MaterialX"
		-DWITH_MATERIALX=$(usex materialx)
		-DWITH_MANIFOLD=$(usex manifold)
		-DWITH_NINJA_POOL_JOBS=no								# for machines with 16GB of RAM or less
		-DBUILD_SHARED_LIBS=no
		#-DWITH_EXPERIMENTAL_FEATURES=yes
		#-Wno-dev
		#-DCMAKE_FIND_DEBUG_MODE=yes
		#-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=yes
		-DWITH_STRICT_BUILD_OPTIONS=yes
		-DWITH_LIBS_PRECOMPILED=no
		-DWITH_BUILDINFO=yes
		-DWITH_UNITY_BUILD=no 									# Enable Unity build for blender modules (memory usage/compile time)
		-DWITH_HYDRA=no 										# MacOS features enabled by default if WITH_STRICT_BUILD_OPTIONS=yes
	)

	if has_version ">=dev-python/numpy-2"; then
		mycmakeargs+=(
			-DPYTHON_NUMPY_INCLUDE_DIRS="$(python_get_sitedir)/numpy/_core/include"
			-DPYTHON_NUMPY_PATH="$(python_get_sitedir)/numpy/_core/include"
		)
	fi

	# CUDA Kernel Selection
	if use cuda; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT};"
		done

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_TARGETS}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_BINARIES_ARCH=${CUDA_TARGETS%%;}

			)
		fi
		mycmakeargs+=(
			-DCUDA_NVCC_FLAGS="--compiler-bindir;$(cuda_gccdir)"
		)
	fi

	if use hip; then
		mycmakeargs+=(
			# -DROCM_PATH="$(hipconfig -R)"
			-DHIP_ROOT_DIR="$(hipconfig -p)"

			-DHIP_HIPCC_FLAGS="-fcf-protection=none"

			# -DHIP_LINKER_EXECUTABLE="$(get_llvm_prefix)/bin/clang++"
			-DCMAKE_HIP_LINK_EXECUTABLE="$(get_llvm_prefix)/bin/clang++"

			-DCYCLES_HIP_BINARIES_ARCH="$(get_amdgpu_flags)"
		)
	fi

	if use llvm; then
		mycmakeargs+=(
			-DLLVM_LIBRARY="/usr/lib/llvm/${LLVM_SLOT}/lib64/libLLVM.so"
		)
	fi

	if use optix; then
		mycmakeargs+=(
			-DCYCLES_RUNTIME_OPTIX_ROOT_DIR="${ESYSROOT}/opt/optix"
			-DOPTIX_ROOT_DIR="${ESYSROOT}/opt/optix"
		)
	fi

	if use wayland; then
		mycmakeargs+=(
			-DWITH_GHOST_WAYLAND_APP_ID="blender-${BV}"
			-DWITH_GHOST_WAYLAND_LIBDECOR="$(usex gnome)"
		)
	fi

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	use arm64 && append-flags -flax-vector-conversions

	append-cflags "$(usex debug '-DDEBUG' '-DNDEBUG')"
	append-cxxflags "$(usex debug '-DDEBUG' '-DNDEBUG')"


	CMAKE_BUILD_TYPE=$(usex debug RelWithDebInfo Release)

	mycmakeargs+=(
		-DWITH_LINKER_LLD=$(usex lld)
		-DWITH_LINKER_GOLD=$(usex gold)
		-DWITH_LINKER_MOLD=$(usex mold)
	)

	if use test; then
		local CYCLES_TEST_DEVICES=( "CPU" )
		if use cycles-bin-kernels; then
			use cuda && CYCLES_TEST_DEVICES+=( "CUDA" )
			use optix && CYCLES_TEST_DEVICES+=( "OPTIX" )
			use hip && CYCLES_TEST_DEVICES+=( "HIP" )
		fi
		mycmakeargs+=(
			-DCMAKE_INSTALL_PREFIX_WITH_CONFIG="${T}/usr"
			-DCYCLES_TEST_DEVICES="$(local IFS=";"; echo "${CYCLES_TEST_DEVICES[*]}")"
		)

		# NOTE in lieu of a FEATURE/build_options
		if [[ "${EXPENSIVE_TESTS:-0}" -gt 0 ]]; then
			einfo "running expensive tests EXPENSIVE_TESTS=${EXPENSIVE_TESTS}"
			mycmakeargs+=(
				-DWITH_CYCLES_TEST_OSL="$(usex osl)"

				-DWITH_GPU_BACKEND_TESTS="yes"
				-DWITH_GPU_COMPOSITOR_TESTS="yes"

				-DWITH_GPU_DRAW_TESTS="yes"

				-DWITH_GPU_RENDER_TESTS="no"
				-DWITH_GPU_RENDER_TESTS_HEADED="no"
				-DWITH_GPU_RENDER_TESTS_SILENT="yes"
				-DWITH_GPU_RENDER_TESTS_VULKAN="$(usex vulkan)"

				-DWITH_SYSTEM_PYTHON_TESTS="yes"
				-DTEST_SYSTEM_PYTHON_EXE="${PYTHON}"
			)

			if [[ "${PV}" == *9999* && "${BVC}" == "alpha" ]] && use experimental; then
				mycmakeargs+=(
					# Enable user-interface tests using a headless display server.
					# Currently this depends on WITH_GHOST_WAYLAND and the weston compositor (Experimental)
					-DWITH_UI_TESTS="$(usex wayland)"
					-DWESTON_BIN="${ESYSROOT}/usr/bin/weston"
				)
			fi
		else
			mycmakeargs+=(
				-DWITH_GPU_RENDER_TESTS="no"
			)
		fi
	fi

	cmake_src_configure
}

src_test() {
	# A lot of tests need to have access to the installed data files.
	# So install them into the image directory now.
	DESTDIR="${T}" cmake_build install

	blender_get_version
	# Define custom blender data/script file paths, or we won't be able to find them otherwise during testing.
	# (Because the data is in the image directory and it will default to look in /usr/share)
	local -x BLENDER_SYSTEM_RESOURCES="${T%/}/usr/share/blender/${BV}"

	# Sanity check that the script and datafile path is valid.
	# If they are not valid, blender will fallback to the default path which is not what we want.
	[[ -d "${BLENDER_SYSTEM_RESOURCES}" ]] || die "The custom resources path is invalid, fix the ebuild!"

	# TODO only picks first card
	addwrite "/dev/dri/card0"
	addwrite "/dev/dri/renderD128"
	addwrite "/dev/udmabuf"

	if use cuda; then
		cuda_add_sandbox -w
		addwrite "/proc/self/task"
		addpredict "/dev/char/"
	fi

	local -x CMAKE_SKIP_TESTS=(
		"^compositor_cpu_color$"
		"^compositor_cpu_filter$"
		"^cycles_image_colorspace_cpu$"
		"^script_pyapi_bpy_driver_secure_eval$"
	)

	if [[ "${RUN_FAILING_TESTS:-0}" -eq 0 ]]; then
		einfo "not running failing tests RUN_FAILING_TESTS=${RUN_FAILING_TESTS}"
		CMAKE_SKIP_TESTS+=(
			"^BLI$"
			"^asset_system$"
			"^cycles$"
			"^cycles_bsdf_cpu$"
			"^cycles_bsdf_cuda$"
			"^cycles_bsdf_optix$"
			"^cycles_displacement_cpu$"
			"^cycles_displacement_cuda$"
			"^cycles_displacement_optix$"
			"^cycles_image_data_types_cpu$"
			"^cycles_image_data_types_cuda$"
			"^cycles_image_data_types_optix$"
			"^cycles_osl_cpu$"
			"^cycles_principled_bsdf_cpu$"
			"^cycles_principled_bsdf_cuda$"
			"^cycles_principled_bsdf_optix$"
			"^cycles_shader_cpu$"
			"^cycles_shader_cuda$"
			"^cycles_shader_optix$"
			"^ffmpeg_libs$" # needs H265
			"^imbuf_save$" # needs oiio with working webp
			"^geo_node_curves_curve_to_points$"
			"^geo_node_geometry_duplicate_elements_curve_points$"
		)
	fi

	if ! has_version "media-libs/openusd"; then
		CMAKE_SKIP_TESTS+=(
			# from pxr import Usd # ModuleNotFoundError: No module named 'pxr'
			"^script_bundled_modules$"
		)
	fi

	if ! has_version "media-libs/openimageio[python]"; then
		CMAKE_SKIP_TESTS+=(
			# import OpenImageIO as oiio # ModuleNotFoundError: No module named 'OpenImageIO'
			"^compositor_cpu_file_output$"
		)
	fi

	# oiio can't find webp due to missing cmake files # 937031
	sed -e "s/ WEBP//g" -i "${BUILD_DIR}/tests/python/CTestTestfile.cmake" || die

	# For debugging, print out all information.
	local -x VERBOSE="$(usex debug "true" "false")"
	"${VERBOSE}" && einfo "VERBOSE=${VERBOSE}"

	# Show the window in the foreground.
	[[ -v USE_WINDOW ]] && einfo "USE_WINDOW=${USE_WINDOW}"

	# local -x USE_DEBUG="true" # non-zero
	[[ -v USE_DEBUG ]] && einfo "USE_DEBUG=${USE_DEBUG}"

	if [[ "${EXPENSIVE_TESTS:-0}" -gt 0 ]]; then
		einfo "running expensive tests EXPENSIVE_TESTS=${EXPENSIVE_TESTS}"

		xdg_environment_reset
		# WITH_GPU_RENDER_TESTS_HEADED
		if use wayland; then
			local compositor exit_code
			local logfile=${T}/weston.log
			weston --xwayland --backend=headless --socket=wayland-5 --idle-time=0 2>"${logfile}" &
			compositor=$!
			local -x WAYLAND_DISPLAY=wayland-5
			sleep 1 # wait for xwayland to be up
			local -x DISPLAY="$(grep "xserver listening on display" "${logfile}" | cut -d ' ' -f 5)"

			cmake_src_test

			exit_code=$?
			kill "${compositor}"
		elif use X; then
			virtx cmake_src_test
		else
			cmake_src_test
		fi
	else
		cmake_src_test
	fi

	# Clean up the image directory for src_install
	rm -fr "${T}/usr" || die
}

src_install() {
	blender_get_version

	# Pax mark blender for hardened support.
	pax-mark m "${BUILD_DIR}/bin/blender"

	cmake_src_install

	if use man; then
		# Slot the man page
		mv "${ED}/usr/share/man/man1/blender.1" "${ED}/usr/share/man/man1/blender-${BV}.1" || die
	fi

	if use doc; then
		# Define custom blender data/script file paths. Otherwise Blender will not be able to find them during doc building.
		# (Because the data is in the image directory and it will default to look in /usr/share)
		local -x BLENDER_SYSTEM_RESOURCES="${ED}/usr/share/blender/${BV}"

		# Workaround for binary drivers.
		addpredict /dev/ati
		addpredict /dev/dri
		addpredict /dev/nvidiactl

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}/doc/doxygen" || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python "doc/python_api/sphinx_doc_gen.py" -noaudio || die "sphinx failed."

		cd "${CMAKE_USE_DIR}/doc/python_api" || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."

		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}/doc/python_api/BPY_API/"

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}/doc/doxygen/html/"
	fi

	# Fix doc installdir
	docinto html
	dodoc "${CMAKE_USE_DIR}/release/text/readme.html"
	rm -r "${ED%/}/usr/share/doc/blender*"
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

	if use osl && ! has_version "media-libs/mesa[${LLVM_USEDEP}]"; then
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
		elog "python_single_target_python3_12 instead."
		elog "Bug: https://bugs.gentoo.org/737388"
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

	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		ewarn
		ewarn "You may want to remove the following directories"
		ewarn "- ~/.config/${PN}/${SLOT}/cache/"
		ewarn "- ~/.cache/cycles/"
		ewarn "It may contain extra render kernels not tracked by portage"
		ewarn
	fi
}
