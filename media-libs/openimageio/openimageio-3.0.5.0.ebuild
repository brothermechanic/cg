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

TEST_OIIO_IMAGE_COMMIT="7e6d875542b5bc1b2974b7cbecee115365a36527"
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
IUSE="aom avif color-management cuda dicom doc ffmpeg fits +gif gui heif jpeg2k jpegxl
opencv tools openvdb +png ptex +python qt5 qt6 +raw rav1e tbb test +truetype wayland +webp X
${CPU_FEATURES[@]%:*} ${CUDA_TARGETS_COMPAT[@]/#/cuda_targets_}"

REQUIRED_USE="
	aom? (
		avif
	)
	avif? (
		|| (
			aom
			rav1e
		)
	)
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
	rav1e? (
		avif
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
	dev-libs/pugixml:=
	>=media-libs/libheif-1.13.0:=
	media-libs/libultrahdr:=
	cuda? ( >=dev-util/nvidia-cuda-toolkit-12.8:= )
	png? ( media-libs/libpng:0= )
	webp? ( >=media-libs/libwebp-1.5.0:= )
	>=dev-libs/imath-3.1.2-r4:=
	color-management? ( >=media-libs/opencolorio-2.1.1-r4:= )
	>=media-libs/openexr-3:0=
	media-libs/tiff:=
	sys-libs/zlib:=
	virtual/jpeg:0
	dicom? ( sci-libs/dcmtk )
	ffmpeg? ( media-video/ffmpeg:= )
	fits? ( sci-libs/cfitsio:= )
	gif? ( media-libs/giflib:0= )
	jpeg2k? ( >=media-libs/openjpeg-2.0:2= )
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
	truetype? ( media-libs/freetype:2= )
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
	"${FILESDIR}/${PN}-2.5.18.0-tests-optional.patch"
)

pkg_setup() {
	use python && python-single-r1_pkg_setup
	use openvdb && openvdb_pkg_setup
}

src_prepare() {
	if ! use dicom; then
		rm "src/dicom.imageio" -r || die
	fi

	if ! use gif; then
		rm src/gif.imageio -r || die
	fi

	if ! use jpeg2k; then
		rm src/jpeg2000.imageio -r || die
	fi

	if ! use raw; then
		rm src/raw.imageio -r || die
	fi

	cmake_src_prepare
	cmake_comment_add_subdirectory src/fonts

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

		-DUSE_DCMTK="$(usex dicom)"
		-DUSE_FFmpeg="$(usex ffmpeg)"
		-DUSE_FITS="$(usex fits)"
		-DUSE_FREETYPE="$(usex truetype)"
		-DUSE_GIF="$(usex gif)"
		-DUSE_LibRaw="$(usex raw)"
		-DUSE_Nuke="no" # not in Gentoo
		-DUSE_OpenCV="$(usex opencv)"
		-DUSE_OpenJPEG="$(usex jpeg2k)"
		-DUSE_JXL="$(usex jpegxl)"
		-DUSE_OpenVDB="$(usex openvdb)"
		-DUSE_TBB="$(usex tbb)"
		-DUSE_Ptex="$(usex ptex)"
		-DUSE_PNG="$(usex png)"
		-DUSE_WEBP="$(usex webp)"

		-DUSE_GIF="$(usex gif)"
		-DUSE_LIBRAW="$(usex raw)"
		-DUSE_PTEX="$(usex ptex)"
		-DUSE_OPENJPEG="$(usex jpeg2k)"

		-DOIIO_USE_CUDA="$(usex cuda)"
		-DOIIO_BUILD_TOOLS="$(usex tools)"
		-DOIIO_BUILD_TESTS="$(usex test)"
		-DOIIO_DOWNLOAD_MISSING_TESTDATA="no"

		-DUSE_CCACHE="no"
		-DUSE_EXTERNAL_PUGIXML="yes"
		-DENABLE_OPENCOLORIO="$(usex color-management)"
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

	CMAKE_BUILD_TYPE='Release'
	cmake_src_configure
}

src_test() {
	# A lot of tests needs to have access to the installed data files.
	# So install them into the image directory now.
	DESTDIR="${T}" cmake_build install

	CMAKE_SKIP_TESTS=(
		"-broken$"
		"texture-levels-stochaniso.batch"
		"unit_simd"
	)

	sed -e "s#../../../testsuite#../../../OpenImageIO-${PV}/testsuite#g" \
		-i "${CMAKE_USE_DIR}/testsuite/python-imagebufalgo/ref/out.txt" || die

	local -x CI CMAKE_PREFIX_PATH LD_LIBRARY_PATH OPENIMAGEIO_FONTS PYTHONPATH
	CI=true
	CMAKE_PREFIX_PATH="${T}/usr"
	LD_LIBRARY_PATH="${T}/usr/$(get_libdir)"
	OPENIMAGEIO_FONTS="${CMAKE_USE_DIR}/src/fonts"

	if use python; then
		PYTHONPATH="${T}$(python_get_sitedir)"
	fi

	virtx cmake_src_test

	# Clean up the image directory for src_install
	rm -fr "${T:?}"/usr || die
}

src_install() {
	cmake_src_install

	# remove Windows loader file
	if use python; then
		rm "${D}$(python_get_sitedir)/__init__.py" || die
	fi
}
