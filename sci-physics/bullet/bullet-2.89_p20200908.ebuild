EAPI=6

inherit cmake-utils

DESCRIPTION="Continuous Collision Detection and Physics Library"
HOMEPAGE="http://www.bulletphysics.com/"
COMMIT="b44307a6ce3c1d07767c23fc20b129a7355da503"
SRC_URI="https://github.com/bulletphysics/bullet3/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="ZLIB"
SLOT="0/${PV}"
KEYWORDS="amd64"
IUSE="+bullet3 doc double-precision examples extras test"

RDEPEND="
	virtual/opengl
	media-libs/freeglut
	dev-libs/tinyxml2
	sys-libs/zlib"

DEPEND="
	${RDEPEND}
	media-gfx/graphviz
	doc? ( app-doc/doxygen[dot] )"

# python3,
# python3-dev,

# rdfind,
# symlinks

PATCHES=(
	"${FILESDIR}"/${PN}-2.85-soversion.patch
	"${FILESDIR}"/disable-Extra-2020-modules.patch
	"${FILESDIR}"/do-not-build-with-embedded-tinyxml-library.patch
)

DOCS=( AUTHORS.txt LICENSE.txt README.md )

# Building / linking of third Party library BussIK does not work out of the box
RESTRICT="test"

S="${WORKDIR}/${PN}3-${COMMIT}"

src_prepare() {
	cmake-utils_src_prepare

	# allow to generate docs
	sed -i -e 's/GENERATE_HTMLHELP.*//g' Doxyfile || die
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_CPU_DEMOS=OFF
		-DBUILD_OPENGL3_DEMOS=OFF
		-DBUILD_BULLET2_DEMOS=OFF
		-DUSE_GRAPHICAL_BENCHMARK=OFF
		-DINSTALL_LIBS=ON
		-DINSTALL_EXTRA_LIBS=ON
		-DBUILD_BULLET3=$(usex bullet3)
		-DBUILD_EXTRAS=$(usex extras)
		-DUSE_DOUBLE_PRECISION=$(usex double-precision)
		-DBUILD_UNIT_TESTS=$(usex test)
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		doxygen || die
		HTML_DOCS+=( html/. )
		DOCS+=( docs/*.pdf )
	fi
}

src_install() {
	cmake-utils_src_install
	use examples && DOCS+=( examples )
	einstalldocs
}
