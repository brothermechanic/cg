# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..10} )

# Check this on updates
LLVM_MAX_SLOT=14

inherit cmake llvm toolchain-funcs python-single-r1

DESCRIPTION="Advanced shading language for production GI renderers"
HOMEPAGE="http://opensource.imageworks.com/?p=osl"
SRC_URI="https://github.com/imageworks/OpenShadingLanguage/archive/v${PV}-dev.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/OpenShadingLanguage-${PV}-dev"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"

X86_CPU_FEATURES=(
	sse2:sse2 sse3:sse3 ssse3:ssse3 sse4_1:sse4.1 sse4_2:sse4.2
	avx:avx avx2:avx2 avx512f:avx512f f16c:f16c
)
CPU_FEATURES=( ${X86_CPU_FEATURES[@]/#/cpu_flags_x86_} )

IUSE="doc optix partio qt5 test ${CPU_FEATURES[@]%:*} python"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	dev-libs/boost:=
	dev-libs/pugixml
	>=media-libs/openexr-3:0=
	>=media-libs/openimageio-2.3.12.0:=
	<sys-devel/clang-$((${LLVM_MAX_SLOT} + 1)):=
	sys-libs/zlib:=
	optix? ( >=dev-libs/optix-7.4.0 )
	partio? ( media-libs/partio )
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			dev-python/pybind11[${PYTHON_USEDEP}]
		')
	)
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

# Restricting tests as Makefile handles them differently
RESTRICT="
	test
	mirror
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.13.4.4-dev-llvm-14.patch
)

llvm_check_deps() {
	has_version -r "sys-devel/clang:${LLVM_SLOT}"
}

pkg_setup() {
	use python && python-single-r1_pkg_setup
	llvm_pkg_setup
}

src_prepare() {
	cmake_src_prepare
	# optix 7.4 build fix
	sed -i -e 's/OPTIX_COMPILE_DEBUG_LEVEL_LINEINFO/OPTIX_COMPILE_DEBUG_LEVEL_MINIMAL/g' src/testshade/optixgridrender.cpp src/testrender/optixraytracer.cpp || die
}

src_configure() {
	local cpufeature
	local mysimd=()
	for cpufeature in "${CPU_FEATURES[@]}"; do
		use "${cpufeature%:*}" && mysimd+=("${cpufeature#*:}")
	done

	# If no CPU SIMDs were used, completely disable them
	[[ -z ${mysimd} ]] && mysimd=("0")

	local gcc="$(tc-getCC)"

	CMAKE_BUILD_TYPE=Release
	local mycmakeargs=(
		-DCMAKE_CXX_STANDARD=14
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DINSTALL_DOCS=$(usex doc)
		-DUSE_CCACHE=OFF
		-DLLVM_STATIC=OFF
		-DOSL_BUILD_TESTS=$(usex test)
				# Breaks build for now: bug #827949
		#-DOSL_BUILD_TESTS=$(usex test)
		-DOSL_SHADER_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/shaders"
		-DOSL_PTX_INSTALL_DIR="${EPREFIX}/usr/include/${PN^^}/ptx"
		-DSTOP_ON_WARNING=OFF
		-DUSE_OPTIX=$(usex optix)
		-DOPTIX_INCLUDE_DIR=/opt/optix/include
		-DUSE_PARTIO=$(usex partio)
		-DUSE_QT=$(usex qt5)
		-DUSE_PYTHON=$(usex python)
		-DUSE_SIMD="$(IFS=","; echo "${mysimd[*]}")"
	)

	cmake_src_configure
}
