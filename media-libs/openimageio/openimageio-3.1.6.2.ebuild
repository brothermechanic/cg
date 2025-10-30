# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
OPENVDB_COMPAT=( {7..12} )
CUDA_TARGETS_COMPAT=(
	sm_30
	sm_50
	sm_60
	sm_61
	sm_70
	sm_75
	sm_80
	sm_86
	sm_90
)

TEST_OIIO_IMAGE_COMMIT="75099275c73a6937d40c69f9e14a006aa49fa201"
TEST_OEXR_IMAGE_COMMIT="d45a2d5a890d6963b94479c7a644440068c37dd2"
inherit cmake cuda flag-o-matic python-single-r1 virtualx openvdb

DESCRIPTION="A library for reading and writing images"
HOMEPAGE="https://sites.google.com/site/openimageio/ https://github.com/OpenImageIO"
SRC_URI="
	https://github.com/AcademySoftwareFoundation/OpenImageIO/archive/v${PV}.tar.gz -> ${P}.tar.gz
	test? (
		https://github.com/AcademySoftwareFoundation/OpenImageIO-images/archive/${TEST_OIIO_IMAGE_COMMIT}.tar.gz
		 -> ${PN}-oiio-test-image-${TEST_OIIO_IMAGE_COMMIT}.tar.gz
		https://github.com/AcademySoftwareFoundation/openexr-images/archive/${TEST_OEXR_IMAGE_COMMIT}.tar.gz
		 -> ${PN}-oexr-test-image-${TEST_OEXR_IMAGE_COMMIT}.tar.gz
		jpeg2k? ( https://www.itu.int/wftp3/Public/t/testsignal/SpeImage/T803/v2002_11/J2KP4files.zip )

		fits? (
			https://www.cv.nrao.edu/fits/data/tests/ftt4b/file001.fits
			https://www.cv.nrao.edu/fits/data/tests/ftt4b/file002.fits
			https://www.cv.nrao.edu/fits/data/tests/ftt4b/file003.fits
			https://www.cv.nrao.edu/fits/data/tests/ftt4b/file009.fits
			https://www.cv.nrao.edu/fits/data/tests/ftt4b/file012.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0001.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0003.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0005.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0006.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0007.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0008.fits
			https://www.cv.nrao.edu/fits/data/tests/pg93/tst0013.fits
		)
	)
"
S="${WORKDIR}/OpenImageIO-${PV}"

LICENSE="Apache-2.0"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86 ~riscv"

X86_CPU_FEATURES=(
	aes:aes sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( "${X86_CPU_FEATURES[@]/#/cpu_flags_x86_}" )
# font install is enabled upstream
# building test enabled upstream
IUSE="+bmp color-management +cineon cuda +dds dicom doc +dpx +ffmpeg fits +gif gui hdr heif htj2k +iff
 jpeg2k jpegxl libcxx opencv tools openvdb +png +pnm ptex +python qt5 qt6 +raw +rla +sgi tbb test +tga +tiff
 +truetype uhdr wayland +webp +xsi X ${CPU_FEATURES[@]%:*} ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"

REQUIRED_USE="
	cuda? (
		|| (
			${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}
		)
	)
	gui? (
		^^ (
			qt5
			qt6
		)
	)
	htj2k? (
		jpeg2k
	)
	openvdb? (
		${OPENVDB_REQUIRED_USE}
		tbb
	)
	python? (
		${PYTHON_REQUIRED_USE}
	)
	tools? (
		gui
	)
	test? (
		tools
		truetype
	)
"


RESTRICT="
	mirror
	!test? ( test )
"

BDEPEND="
	cuda? ( >=dev-util/nvidia-cuda-toolkit-12.8:= )
	jpeg2k? ( app-arch/unzip )
	doc? (
		app-text/doxygen
		dev-texlive/texlive-bibtexextra
		dev-texlive/texlive-fontsextra
		dev-texlive/texlive-fontutils
		dev-texlive/texlive-latex
		dev-texlive/texlive-latexextra
	)
"
RDEPEND="
	dev-libs/boost:=
	dev-cpp/robin-map
	dev-libs/libfmt:=
	dev-libs/pugixml
	heif? ( >=media-libs/libheif-1.13.0:= )
	htj2k? ( media-libs/openjph:= )
	uhdr? ( media-libs/libultrahdr:= )
	cuda? ( >=dev-util/nvidia-cuda-toolkit-12.8:= )
	png? ( media-libs/libpng:0= )
	webp? ( >=media-libs/libwebp-1.6.0:= )
	>=dev-libs/imath-3.1.2-r4:=
	color-management? ( >=media-libs/opencolorio-2.1.1-r4:= )
	>=media-libs/openexr-3:0=
	sys-libs/zlib:=
	virtual/jpeg:0
	dicom? ( sci-libs/dcmtk )
	ffmpeg? ( media-video/ffmpeg:= )
	fits? ( sci-libs/cfitsio:= )
	gif? ( media-libs/giflib:= )
	jpeg2k? ( media-libs/openjpeg:= )
	jpegxl? ( media-libs/libjxl:= )
	opencv? ( media-libs/opencv:= )
	openvdb? (
		dev-cpp/tbb:=
		media-gfx/openvdb:=[${OPENVDB_SINGLE_USEDEP}]
	)
	ptex? ( media-libs/ptex:= )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-libs/boost:=[python,${PYTHON_USEDEP}]
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
	gui? (
		media-libs/libglvnd
		!qt6? (
			dev-qt/qtcore:5
			dev-qt/qtgui:5
			dev-qt/qtopengl:5
			dev-qt/qtwidgets:5
		)
		qt6? (
			dev-qt/qtbase:6[gui,widgets,opengl]
		)
	)
	raw? ( media-libs/libraw:= )
	tiff? ( media-libs/tiff:= )
	truetype? ( media-libs/freetype )
"
DEPEND="
	${RDEPEND}
"

DOCS=(
	CHANGES.md
	CREDITS.md
	README.md
)

QA_PRESTRIPPED="usr/lib/python.*/site-packages/.*"

PATCHES=(
	"${FILESDIR}/${PN}-2.5.8.0-fix-tests.patch"
	"${FILESDIR}/${PN}-2.5.12.0-heif-find-fix.patch"
#	"${FILESDIR}/${PN}-2.5.18.0-tests-optional.patch"
	"${FILESDIR}/${PN}-3.0.8.1-fix-alpha-pr3934.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use openvdb && openvdb_pkg_setup
}

src_prepare() {
	use bmp || ( rm "src/bmp.imageio" -r || die )
	use cineon || ( rm "src/cineon.imageio" -r || die )
	use dicom || ( rm "src/dicom.imageio" -r || die )
	use dpx || ( rm "src/dpx.imageio" -r || die )
	use dds || ( rm "src/dds.imageio" -r || die )
	use gif || ( rm "src/gif.imageio" -r || die )
	use jpeg2k || ( rm "src/jpeg2000.imageio" -r || die )
	use raw || ( rm "src/raw.imageio" -r || die )
	use fits || ( rm "src/fits.imageio" -r || die )
	use heif || ( rm "src/heif.imageio" -r || die )
	use hdr || ( rm "src/hdr.imageio" -r || die )
	use pnm || ( rm "src/pnm.imageio" -r || die )
	use rla || ( rm "src/rla.imageio" -r || die )
	use sgi || ( rm "src/sgi.imageio" -r || die )
	use tga || ( rm "src/targa.imageio" -r || die )
	use tiff || ( rm "src/tiff.imageio" -r || die )
	use webp || ( rm "src/webp.imageio" -r || die )
	use xsi || ( rm "src/softimage.imageio" -r || die )

	# remove non Linux plugins
	rm "src/nuke" -r || die
	rm "src/ico.imageio" -r || die
	rm "src/r3d.imageio" -r || die
	rm "src/psd.imageio" -r || die

	cmake_src_prepare
	cmake_comment_add_subdirectory src/fonts

	# use elibc_musl && eapply "${FILESDIR}/${PN}-3.0.8.1-musl-64bit.patch"

	if ! use color-management; then
		sed \
			-e 's/checked_find_package (OpenColorIO REQUIRED/checked_find_package (OpenColorIO CONFIG/' \
		    -e '/if (NOT OPENCOLORIO_INCLUDES)/,/include_directories(BEFORE ${OPENCOLORIO_INCLUDES})/d' \
		    -i src/cmake/externalpackages.cmake || die
		sed \
			-e '/OpenColorIO::OpenColorIO/d' \
			-e 's/color_ocio.cpp//g' \
			-i src/libOpenImageIO/CMakeLists.txt
	fi

	if use test ; then
		ln -s "${WORKDIR}/OpenImageIO-images-${TEST_OIIO_IMAGE_COMMIT}" "${WORKDIR}/oiio-images" || die
		ln -s "${WORKDIR}/openexr-images-${TEST_OEXR_IMAGE_COMMIT}" "${WORKDIR}/openexr-images" || die

		if use fits; then
			mkdir -p "${WORKDIR}/fits-images/"{ftt4b,pg93} || die
			for a in ${A}; do
				if [[ "${a}" == file*.fits ]]; then
					ln -s "${DISTDIR}/${a}" "${WORKDIR}/fits-images/ftt4b/" || die
				fi
				if [[ "${a}" == tst*.fits ]]; then
					ln -s "${DISTDIR}/${a}" "${WORKDIR}/fits-images/pg93/" || die
				fi
			done
		fi

		if use jpeg2k; then
			ln -s "${WORKDIR}/J2KP4files" "${WORKDIR}/j2kp4files_v1_5" || die
		fi

		cp testsuite/heif/ref/out-libheif1.1{2,5}-orient.txt || die
		eapply "${FILESDIR}/${PN}-2.5.12.0_heif_test.patch"
	fi

	if use cuda; then
		cuda_src_prepare
		addpredict "/proc/self/task/"
	fi
}

src_configure() {
	use openvdb && openvdb_src_configure
	# Build with SIMD support
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	# If no CPU SIMDs were used, completely disable them
	[[ -z ${mysimd[*]} ]] && mysimd=("0")

	# This is currently needed on arm64 to get the NEON SIMD wrapper to compile the code successfully
	# Even if there are no SIMD features selected, it seems like the code will turn on NEON support if it is available.
	use arm64 && append-flags -flax-vector-conversions

	# https://gcc.gnu.org/bugzilla/show_bug.cgi?id=118077
	if tc-is-gcc && [[ $(gcc-major-version) -eq 15 ]]; then
		append-flags -fno-early-inlining
	fi

	strip-unsupported-flags

	local mycmakeargs=(
		-DVERBOSE="yes"
		# -DALWAYS_PREFER_CONFIG="yes"
		# -DGLIBCXX_USE_CXX11_ABI="yes"
		# -DTEX_BATCH_SIZE="8" # TODO AVX512 -> 16
		-DSTOP_ON_WARNING="OFF"

		-DCMAKE_CXX_STANDARD="17"
		-DDOWNSTREAM_CXX_STANDARD="17"

		-DCMAKE_UNITY_BUILD_MODE="BATCH"
		-DUNITY_SMALL_BATCH_SIZE="$(nproc)"

		-DBUILD_DOCS="$(usex doc)"
		-DBUILD_TESTING="$(usex test)"

		-DINSTALL_FONTS="OFF"
		-DINSTALL_DOCS="$(usex doc)"
		-DENABLE_BMP="$(usex bmp)"
		-DENABLE_CINEON="$(usex cineon)"
		-DENABLE_DPX="$(usex dpx)"
		-DENABLE_DDS="$(usex dds)"
		-DENABLE_DCMTK="$(usex dicom)"
		-DENABLE_FFmpeg="$(usex ffmpeg)"
		-DENABLE_FITS="$(usex fits)"
		-DENABLE_FREETYPE="$(usex truetype)"
		-DENABLE_GIF="$(usex gif)"
		-DENABLE_HDR="$(usex hdr)"
		-DENABLE_IFF="$(usex iff)"
		-DENABLE_LibRaw="$(usex raw)"
		-DENABLE_Nuke="no" # not in Gentoo
		-DENABLE_OpenCV="$(usex opencv)"
		-DENABLE_OpenJPEG="$(usex jpeg2k)"
		-DENABLE_JXL="$(usex jpegxl)"
		-DENABLE_OpenVDB="$(usex openvdb)"
		-DENABLE_TBB="$(usex tbb)"
		-DENABLE_Ptex="$(usex ptex)"
		-DENABLE_PNG="$(usex png)"
		-DENABLE_PNM="$(usex pnm)"
		-DENABLE_RLA="$(usex rla)"
		-DENABLE_SGI="$(usex sgi)"
		-DENABLE_SOFTIMAGE="$(usex xsi)"
		-DENABLE_TARGA="$(usex tga)"
		-DENABLE_libuhdr="$(usex uhdr)"
		-DENABLE_WEBP="$(usex webp)"
		-DENABLE_OPENCOLORIO="$(usex color-management)"
		-DENABLE_LIBRAW="$(usex raw)"
		-DOIIO_BUILD_TOOLS="$(usex tools)"
		-DOIIO_BUILD_TESTS="$(usex test)"
		-DOIIO_DOWNLOAD_MISSING_TESTDATA="no"
		-DOIIO_USE_CUDA="$(usex cuda)"
		-DUSE_CCACHE="no"
		-DUSE_EXTERNAL_PUGIXML="yes"
		-DLINKSTATIC="OFF"
		-DUSE_R3DSDK="no" # not in Gentoo

		-DUSE_PYTHON="$(usex python)"
		-DUSE_SIMD="$(local IFS=','; echo "${mysimd[*]}")"
	)

	if use gui; then
		mycmakeargs+=(
			-DUSE_IV="yes"
			-DUSE_OPENGL="yes"
			-DUSE_QT="yes"
		)
		if ! use qt6; then
			mycmakeargs+=( -DCMAKE_DISABLE_FIND_PACKAGE_Qt6="yes" )
		fi
	else
		mycmakeargs+=(
			-DUSE_QT="no"
		)
	fi

	if use cuda ; then
		for CT in ${CUDA_TARGETS_COMPAT[@]}; do
			use ${CT/#/cuda_targets_} && CUDA_TARGETS+="${CT};"
		done

		mycmakeargs+=(
			-DCUDA_TARGET_ARCH="${CUDA_TARGETS%%;}"
			-DCUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
		)
	fi

	if use python; then
		mycmakeargs+=(
			"-DPYTHON_VERSION=${EPYTHON#python}"
			"-DPYTHON_SITE_DIR=$(python_get_sitedir)"
		)
	fi

	# checks CMAKE_COMPILER_IS_CLANG
	if tc-is-clang; then
		mycmakeargs+=(
			-DUSE_LIBCPLUSPLUS="$(usex libcxx)"
		)
	fi

	CMAKE_BUILD_TYPE='Release' cmake_src_configure
}

src_test() {
	# A lot of tests needs to have access to the installed data files.
	# So install them into the image directory now.
	DESTDIR="${T}" cmake_build install

	if use cuda; then
		cuda_add_sandbox -w
		addwrite "/proc/self/task/"
		addpredict "/dev/char/"
	fi

	CMAKE_SKIP_TESTS=(
		"-broken$"

		"^docs-examples-cpp$"
		"^docs-examples-python$"
		"texture-interp-bilinear.batch$"
		"texture-interp-closest.batch$"
		"texture-levels-stochaniso.batch$"
		"texture-levels-stochmip.batch$"
		"texture-mip-onelevel.batch$"
		"texture-mip-stochastictrilinear.batch$"
		"texture-mip-stochasticaniso.batch$"
		"^python-imagebufalgo$"

		"^oiiotool-text$"
		"^bmp$"
		"^dds$"
		"^ico$"
		"^jpeg2000$"
		"^psd$"
		"^ptex$"

		"^tiff-depths" # TODO float errors
		"^tiff-suite" # TODO missing compresion
		"unit_simd"
	)

	sed -e "s#../../../testsuite#../../../OpenImageIO-${PV}/testsuite#g" \
		-i "${CMAKE_USE_DIR}/testsuite/python-imagebufalgo/ref/out.txt" || die

	# NOTE src/build-scripts/ci-startup.bash
	local -x CI CMAKE_PREFIX_PATH LD_LIBRARY_PATH OPENIMAGEIO_FONTS PYTHONPATH
	CI=true
	local -x OpenImageIO_CI=true
	# local -x OIIO_USE_CUDA=0
	CMAKE_PREFIX_PATH="${T}/usr"
	LD_LIBRARY_PATH="${T}/usr/$(get_libdir)"
	OPENIMAGEIO_FONTS="${CMAKE_USE_DIR}/src/fonts"
	# local -x OPENIMAGEIO_DEBUG_FILE
	local -x OPENIMAGEIO_DEBUG=0

	if use python; then
		PYTHONPATH="${T}$(python_get_sitedir)"
	fi

	myctestargs=(
		--output-on-failure
	)

	cmake_src_test

	# Clean up the image directory for src_install
	rm -fr "${T:?}"/usr || die
}

src_install() {
	cmake_src_install

	# remove Windows loader file
	if use python; then
		rm "${D}$(python_get_sitedir)/__init__.py" || die
		rm "${D}$(python_get_sitedir)/py.typed" || die
	fi
}
