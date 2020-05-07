# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_7 python3_8 )

inherit git-r3 check-reqs cmake-utils python-single-r1 gnome2-utils xdg-utils pax-utils toolchain-funcs flag-o-matic

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org/"

EGIT_REPO_URI="https://git.blender.org/blender"
#EGIT_BRANCH="master"

LICENSE="|| ( GPL-2 BL )"
SLOT="28"
KEYWORDS=""
MY_PV="2.83"

IUSE_DESKTOP="-portable +blender +X +addons +addons-contrib +nls -ndof -player"
IUSE_GPU="+opengl -optix cuda opencl -sm_30 -sm_35 -sm_50 -sm_52 -sm_61 -sm_70 -sm_75"
IUSE_LIBS="+cycles -sdl jack openal freestyle -osl +openvdb +opensubdiv +opencolorio +openimageio +collada -alembic +fftw +oidn +usd"
IUSE_CPU="openmp -embree +sse"
IUSE_TEST="-valgrind -debug -doc"
IUSE_IMAGE="-dpx -dds +openexr jpeg2k tiff +hdr"
IUSE_CODEC="avi +ffmpeg -sndfile +quicktime"
IUSE_COMPRESSION="-lzma +lzo"
IUSE_MODIFIERS="+fluid +smoke +oceansim +quadriflow"
IUSE="${IUSE_DESKTOP} ${IUSE_GPU} ${IUSE_LIBS} ${IUSE_CPU} ${IUSE_TEST} ${IUSE_IMAGE} ${IUSE_CODEC} ${IUSE_COMPRESSION} ${IUSE_MODIFIERS}"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	alembic? ( openexr )
	fluid  ( fftw )
	oceansim ( fftw )
	smoke ( fftw )
	tiff ( openimageio )
	openexr ( openimageio )
	cuda? ( cycles openimageio )
	cycles? ( openexr tiff openimageio opencolorio )
	osl? ( cycles )
	embree? ( cycles )
	oidn? ( cycles )"

LANGS="en ar bg ca cs de el es es_ES fa fi fr he hr hu id it ja ky ne nl pl pt pt_BR ru sr sr@latin sv tr uk zh_CN zh_TW"
for X in ${LANGS} ; do
	IUSE+=" linguas_${X}"
	REQUIRED_USE+=" linguas_${X}? ( nls )"
done

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		dev-python/requests[${PYTHON_MULTI_USEDEP}]
	')
	dev-libs/jemalloc
	sys-libs/zlib
	sci-libs/ceres-solver
	smoke? ( sci-libs/fftw:3.0 )
	media-libs/freetype
	media-libs/libpng:0=
	virtual/libintl
	virtual/jpeg:0=
	dev-libs/boost[nls?,threads(+)]
	opengl? (
		virtual/opengl
		media-libs/glew:*
		virtual/glu
	)
	X? (
	   x11-libs/libXi
	   x11-libs/libX11
	   x11-libs/libXxf86vm
	)
	opencolorio? ( media-libs/opencolorio )
	cycles? (
		openimageio? ( >=media-libs/openimageio-1.1.5 )
		cuda? ( dev-util/nvidia-cuda-toolkit )
		osl? ( media-libs/osl )
		embree? ( media-libs/embree[static-libs,raymask,tbb] )
		openvdb? ( media-gfx/openvdb
		dev-cpp/tbb )
	)
	optix? ( dev-libs/optix )
	sdl? ( media-libs/libsdl[sound,joystick] )
	tiff? ( media-libs/tiff:0 )
	openexr? ( media-libs/openexr )
	ffmpeg? ( >=media-video/ffmpeg-2.2[x264,xvid,mp3,encode,jpeg2k?] )
	jpeg2k? ( media-libs/openjpeg:0 )
	jack? ( media-sound/jack-audio-connection-kit )
	sndfile? ( media-libs/libsndfile )
	collada? ( media-libs/opencollada )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	quicktime? ( media-libs/libquicktime )
	valgrind? ( dev-util/valgrind )
	lzma? ( app-arch/lzma )
	lzo? ( dev-libs/lzo )
	alembic? ( media-gfx/alembic[boost,-hdf] )
	opencl? ( virtual/opencl )
	opensubdiv? ( media-libs/opensubdiv )
	nls? ( virtual/libiconv )
	oidn? ( media-libs/oidn )
	usd? ( media-libs/openusd )"

DEPEND="${RDEPEND}
	dev-cpp/eigen:3
	>=dev-cpp/glog-0.4.0
	>=dev-cpp/gflags-2.2.2
	nls? ( sys-devel/gettext )
	doc? (
		dev-python/sphinx
		app-doc/doxygen[-nodot(-),dot(+)]
	)"

#PATCHES=(
#	"${FILESDIR}/blender-doxyfile.patch"
#)
	
CMAKE_BUILD_TYPE="Release"

blender_check_requirements() {
	[[ ${MERGE_TYPE} != binary ]] && use openmp && tc-check-openmp

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_pretend() {
	blender_check_requirements
}

pkg_setup() {
	blender_check_requirements
	python-single-r1_pkg_setup
}

src_prepare() {
	default
	# remove some bundled deps
	rm -r \
		extern/glew \
		extern/glew-es \
		extern/Eigen3 \
		extern/lzma \
		extern/lzo \
		extern/gtest \
		|| die
    
	if use addons ; then
		ewarn "$(echo "Bundled addons")"
	else
		rm -r release/scripts/addons/*
	fi
	if use addons-contrib ; then
		ewarn "$(echo "Bundled addons")"
	else
		rm -r release/scripts/addons_contrib/*
	fi

		# we don't want static glew, but it's scattered across
	# multiple files that differ from version to version
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	local file
	while IFS="" read -d $'\0' -r file ; do
		sed -i -e '/-DGLEW_STATIC/d' "${file}" || die
	done < <(find . -type f -name "CMakeLists.txt")

	# Disable MS Windows help generation. The variable doesn't do what it
	# it sounds like.
	sed -e "s|GENERATE_HTMLHELP      = YES|GENERATE_HTMLHELP      = NO|" \
	    -i doc/doxygen/Doxyfile || die
	ewarn "$(echo "Remaining bundled dependencies:";
			( find extern -mindepth 1 -maxdepth 1 -type d; ) | sed 's|^|- |')"
	# linguas cleanup
	local i
	if ! use nls; then
		rm -r "${S}"/release/datafiles/locale || die
	else
		if [[ -n "${LINGUAS+x}" ]] ; then
			cd "${S}"/release/datafiles/locale/po
			for i in *.po ; do
				mylang=${i%.po}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi
	cmake-utils_src_prepare
}

src_configure() {
	append-flags -funsigned-char -fno-strict-aliasing
	append-lfs-flags
	append-cppflags -DOPENVDB_ABI_VERSION_NUMBER=6
	local mycmakeargs=""
	#CUDA Kernel Selection
	local CUDA_ARCH=""
	if use cuda; then
		for CA in 30 35 50 52 61 70 75; do
			if use sm_${CA}; then
				if [[ -n "${CUDA_ARCH}" ]] ; then
					CUDA_ARCH="${CUDA_ARCH};sm_${CA}"
				else
					CUDA_ARCH="sm_${CA}"
				fi
			fi
		done

		#If a kernel isn't selected then all of them are built by default
		if [ -n "${CUDA_ARCH}" ] ; then
			mycmakeargs+=(
				-DCYCLES_CUDA_BINARIES_ARCH=${CUDA_ARCH}
			)
		fi
		mycmakeargs+=(
			-DWITH_CYCLES_CUDA=ON
			-DWITH_CYCLES_CUDA_BINARIES=ON
			-DCUDA_INCLUDES=/opt/cuda/include
			-DCUDA_LIBRARIES=/opt/cuda/lib64
			-DCUDA_NVCC_EXECUDABLE=/opt/cuda/bin/nvcc
			-DCUDA_NVCC_FLAGS=-std=c++11
		)
	fi
	
	if use optix; then
		mycmakeargs+=(
			-OPTIX_ROOT_DIR=/opt/optix
			-DOPTIX_INCLUDE_DIR=/opt/optix/include
			-DWITH_CYCLES_DEVICE_OPTIX=ON
		)
	fi

	mycmakeargs+=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPYTHON_VERSION=${EPYTHON/python/}
		-DPYTHON_LIBRARY=$(python_get_library_path)
		-DPYTHON_INCLUDE_DIR=$(python_get_includedir)
		-DWITH_PYTHON_INSTALL=$(usex portable)
		-DWITH_PYTHON_INSTALL_NUMPY=$(usex portable)
		-DWITH_PYTHON_INSTALL_REQUESTS=$(usex portable)
		-DWITH_PYTHON_MODULE=$(usex !X)
		-DWITH_HEADLESS=$(usex !X)
		-DWITH_BLENDER=$(usex blender)
		-DWITH_ALEMBIC=$(usex alembic)
		-DWITH_CODEC_AVI=$(usex avi)
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg)
		-DWITH_CODEC_SNDFILE=$(usex sndfile)
		-DWITH_FFTW3=$(usex fftw)
		-DWITH_CPU_SSE=$(usex sse)
		-DWITH_CYCLES=$(usex cycles)
		-DWITH_CYCLES_DEVICE_CUDA=$(usex cuda)
		-DWITH_CYCLES_DEVICE_OPENCL=$(usex opencl)
		-DWITH_CYCLES_EMBREE=$(usex embree)
		-DWITH_CYCLES_NATIVE_ONLY=$(usex cycles)
		-DWITH_CYCLES_OSL=$(usex osl)
		-DWITH_CYCLES_STANDALONE=OFF
		-DWITH_CYCLES_STANDALONE_GUI=OFF
		-DWITH_FREESTYLE=$(usex freestyle)
		-DWITH_X11=$(usex X)
		-DWITH_GHOST_XDND=$(usex X)
		-DWITH_IMAGE_CINEON=$(usex dpx)
		-DWITH_IMAGE_DDS=$(usex dds)
		-DWITH_IMAGE_HDR=$(usex hdr)
		-DWITH_IMAGE_OPENEXR=$(usex openexr)
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k)
		-DWITH_IMAGE_TIFF=$(usex tiff)
		-DWITH_INPUT_NDOF=$(usex ndof)
		-DWITH_INSTALL_PORTABLE=$(usex portable)
		-DWITH_INTERNATIONAL=$(usex nls)
		-DWITH_JACK=$(usex jack)
		-DWITH_LZMA=$(usex lzma)
		-DWITH_LZO=$(usex lzo)
		-DWITH_VALGRIND=$(usex valgrind)
		-DWITH_MOD_FLUID=$(usex fluid)
		-DWITH_MOD_OCEANSIM=$(usex oceansim)
		-DWITH_MOD_SMOKE=$(usex smoke)
		-DWITH_OPENAL=$(usex openal)
		-DWITH_OPENCOLLADA=$(usex collada)
		-DWITH_OPENCOLORIO=$(usex opencolorio)
		-DWITH_OPENGL=$(usex opengl)
		-DWITH_OPENIMAGEDENOISE=$(usex oidn)
		-DWITH_OPENIMAGEIO=$(usex openimageio)
		-DWITH_OPENMP=$(usex openmp)
		-DWITH_OPENSUBDIV=$(usex opensubdiv)
		-DWITH_OPENVDB=$(usex openvdb)
		-DWITH_OPENVDB_BLOSC=$(usex openvdb)
		-DWITH_RAYOPTIMIZATION=$(usex sse)
		-DWITH_QUADRIFLOW=$(usex quadriflow)
		-DWITH_SDL=$(usex sdl)
		-DWITH_SDL_DYNLOAD=$(usex sdl)
		-DWITH_STATIC_LIBS=$(usex portable)
		-DWITH_SYSTEM_EIGEN3=$(usex !portable)
		-DWITH_SYSTEM_GLES=$(usex !portable)
		-DWITH_SYSTEM_GLEW=$(usex !portable)
		-DWITH_SYSTEM_LZO=$(usex !portable)
		-DWITH_GHOST_DEBUG=$(usex debug)
		-DWITH_CXX_GUARDEDALLOC=$(usex debug)
		-DWITH_USD=$(usex usd)
		-DUSD_ROOT_DIR=/usr/local
		-DUSD_LIBRARY=/usr/local/lib/libusd_ms.so
		-DWITH_TBB=ON
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_test() { :; }

src_install() {
	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/.

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/.
	fi

	cmake-utils_src_install

	# fix doc installdir
	docinto "html"
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	python_fix_shebang "${ED%/}/usr/bin/blender-thumbnailer.py"
	python_optimize "${ED%/}/usr/share/blender/${MY_PV}/scripts"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender compiles from master thunk by default"
	elog
	elog "There is some my prefer blender settings as patches"
	elog "find them in cg/local-patches/blender/"
	elog "To apply someone copy them in "
	elog "/etc/portage/patches/media-gfx/blender/"
	elog "or create simlink"
	elog
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update

	ewarn ""
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${MY_PV}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn ""
}
