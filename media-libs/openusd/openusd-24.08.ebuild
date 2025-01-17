# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
OPENVDB_COMPAT=( {7..11} )
inherit cmake desktop python-single-r1 flag-o-matic openvdb xdg-utils

DESCRIPTION="Universal Scene Description"
HOMEPAGE="http://www.openusd.org"
LICENSE="
	Apache-2.0
	BSD
	BSD-2
	JSON
	MIT
"
# custom - https://github.com/PixarAnimationStudios/OpenUSD/blob/v24.05/pxr/usdImaging/usdImaging/drawModeStandin.cpp#L9
# custom - search "In consideration of your agreement"
SLOT="0"
KEYWORDS="~amd64"
# test USE flag is enabled upstream
IUSE="alembic debug -doc draco embree examples hdf5 +imaging +jemalloc
materialx monolithic color-management opengl openimageio openvdb openexr osl
ptex +python safety-over-speed -static-libs tutorials -test tools usdview vulkan"

REQUIRED_USE+="
	${PYTHON_REQUIRED_USE}
	alembic? (
		openexr
	)
	embree? (
		imaging
	)
	hdf5? (
		alembic
	)
	color-management? (
		imaging
	)
	opengl? (
		imaging
	)
	openimageio? (
		imaging
	)
	openvdb? (
		${OPENVDB_REQUIRED_USE}
		imaging
		openexr
	)
	osl? (
		openexr
	)
	ptex? (
		imaging
	)
	test? (
		python
	)
	usdview? (
		opengl
		python
	)
"

RDEPEND+="
	!python? (
		>=dev-libs/boost-1.76.0
	)
	>=sys-libs/zlib-1.2.11
	alembic? (
		>=media-gfx/alembic-1.8.5[hdf5?]
	)
	draco? (
		>=media-libs/draco-1.4.3
	)
	embree? (
		>=media-libs/embree-4.2.0
	)
	>=dev-cpp/tbb-2021.9:=
	hdf5? (
		>=sci-libs/hdf5-1.10[cxx,hl]
	)
	imaging? (
		>=media-libs/opensubdiv-3.6.0
		x11-libs/libX11
	)
	jemalloc? (
		dev-libs/jemalloc-usd
	)
	materialx? (
		>=media-libs/materialx-1.38.7:=[renderer]
	)
	color-management? (
		>=media-libs/opencolorio-2.1.3
	)
	openexr? (
		>=media-libs/openexr-3.1.5-r1:=
	)
	opengl? (
		>=media-libs/glew-2.0.0
	)
	openimageio? (
		>=media-libs/libpng-1.6.29
		>=media-libs/openimageio-2.3.21.0:=
		>=media-libs/tiff-4.0.7
		virtual/jpeg
	)
	openvdb? (
		>=dev-libs/c-blosc-1.17
		>=media-gfx/openvdb-9.1.0[${OPENVDB_SINGLE_USEDEP}]
	)
	osl? (
		>=media-libs/osl-1.10.9
	)
	ptex? (
		>=media-libs/ptex-2.4.2
	)
	python? (
		${PYTHON_DEPS}
		$(python_gen_cond_dep '
			>=dev-libs/boost-1.76.0:=[python,${PYTHON_USEDEP}]
			usdview? (
				(
					>=dev-python/pyside6-6.2.0[${PYTHON_USEDEP},quick(+)]
				)
				dev-python/pyside6-tools[${PYTHON_USEDEP},tools(+)]
				dev-python/shiboken6[${PYTHON_USEDEP}]
				opengl? (
					>=dev-python/pyopengl-3.1.5[${PYTHON_USEDEP}]
				)
			)
		')
	)
    vulkan? (
		>=dev-util/vulkan-headers-1.3.243.0
		>=dev-libs/vulkan-memory-allocator-3.0.0
		>=dev-libs/spirv-reflect-1.3.296.0
		>=dev-util/spirv-headers-1.3.296.0
		>=dev-util/glslang-1.3.296.0
	)
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	$(python_gen_cond_dep '
		>=dev-python/jinja2-2[${PYTHON_USEDEP}]
	')
	>=dev-build/cmake-3.17.5
	app-alternatives/yacc
	app-alternatives/lex
	dev-cpp/argparse
	dev-util/patchelf
	virtual/pkgconfig
	doc? (
		>=app-text/doxygen-1.9.6[dot]
	)
	|| (
		(
			<sys-devel/gcc-15
			>=sys-devel/gcc-9.0.1
		)
		<llvm-core/clang-20
	)
"
SRC_URI="
https://github.com/PixarAnimationStudios/USD/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz
"
RESTRICT="mirror"

PATCHES=(
	"${FILESDIR}/algorithm.patch"
	"${FILESDIR}/packageUtils.cpp.patch"
	"${FILESDIR}/openusd-23.11-defaultfonts.patch"
	"${FILESDIR}/openusd-21.11-gcc-11-numeric_limits.patch"
	"${FILESDIR}/openusd-23.11-fix-vulkan-blit-3382.patch"
	"${FILESDIR}/openusd-21.11-use-whole-archive-for-lld.patch"
	"${FILESDIR}/openusd-24.08-ONEtbb-based-on-3207.patch"
	"${FILESDIR}/openusd-24.08-fix-monolithic-build-2400.patch"
	"${FILESDIR}/openusd-24.08-fix-materialx-build-3159.patch"
	"${FILESDIR}/openusd-24.08-fix-materialx-plugin-resources-2904.patch"
	"${FILESDIR}/openusd-24.08-fix-onetbb-2022-interface-3392.patch"
	"${FILESDIR}/openusd-24.08-fix-openimageio3-plugin-3365.patch"
	#"${FILESDIR}/openusd-24.08-embree-4-plugin-2313.patch"
	"${FILESDIR}/openusd-24.08-PVS-bugfix-base-trace-2313.patch"
	"${FILESDIR}/openusd-24.08-PVS-bugfix-envvar-2157.patch"
	"${FILESDIR}/openusd-24.08-PVS-bugfix-base-tf-2161.patch"
	"${FILESDIR}/openusd-24.08-PVS-bugfix-usd-2165.patch"
)
S="${WORKDIR}/OpenUSD-${PV}"
DOCS=( CHANGELOG.md README.md )

pkg_setup() {
	if use vulkan ; then
		if [[ -z "${VULKAN_SDK}" ]] ; then
			ewarn
			ewarn "VULKAN_SDK should be set as a per-package environmental variable"
			ewarn
			export VULKAN_SDK="${EPREFIX}/usr/include/vulkan"
		fi
	fi
	use python && python-single-r1_pkg_setup
	use openvdb && openvdb_pkg_setup
}

gen_pyside6_uic_file() {
	echo -e "#!"${EPREFIX}"/bin/bash\n/usr/"$(get_libdir)"/qt6/libexec/uic -g python \$@" > pyside6-uic
}

src_prepare() {
	cmake_src_prepare

	# Fix for #2351
	sed -i 's|CMAKE_CXX_STANDARD 14|CMAKE_CXX_STANDARD 17|g' \
		cmake/defaults/CXXDefaults.cmake || die

	# Fix python dirs
	if use python ; then
		eapply "${FILESDIR}/${PN}-23.11-fix-python.patch"
		sed -i 's|/python|/python'${EPYTHON/python}/site-packages'|g' cmake/macros/Private.cmake
  		sed -i 's|lib/python/pxr|'$(python_get_sitedir)'/pxr|' cmake/macros/{Private,Public}.cmake pxr/usdImaging/usdviewq/CMakeLists.txt
  	fi

	# Support Embree4
	if use embree && has_version >=media-libs/embree-4.0.0 ; then
		find . -type f -exec gawk '/embree3/ { print FILENAME }' '{}' '+' | xargs -r sed -r -i 's/(embree)3/\14/'
	fi

	# make dummy pyside-uid
	if use usdview ; then
		gen_pyside6_uic_file
		chmod +x pyside6-uic
	fi
}

src_configure() {
	CMAKE_BUILD_TYPE=$(usex debug 'Debug' 'Release')
	append-cppflags $(usex debug '-DDEBUG' '-DNDEBUG')
	append-cppflags -DTBB_ALLOCATOR_TRAITS_BROKEN
	export USD_PATH="/usr/$(get_libdir)/${PN}"
	use openvdb && openvdb_src_configure
	if use draco; then
		append-cppflags \
			-DDRACO_ATTRIBUTE_INDICES_DEDUPLICATION_SUPPORTED=ON \
			-DDRACO_ATTRIBUTE_VALUES_DEDUPLICATION_SUPPORTED=ON \
			-DTBB_SUPPRESS_DEPRECATED_MESSAGES=1
	fi
    # See https://github.com/PixarAnimationStudios/USD/blob/v24.05/cmake/defaults/Options.cmake
	local mycmakeargs+=(
		$(usex jemalloc "-DPXR_MALLOC_LIBRARY=${ESYSROOT}/usr/$(get_libdir)/${PN}/$(get_libdir)/libjemalloc.so" "")
		$(usex usdview "-DPYSIDEUICBINARY:PATH=${S}/pyside6-uic" "")
		-DBUILD_SHARED_LIBS=ON
		-DCMAKE_CXX_STANDARD=17
		-DPXR_VALIDATE_GENERATED_CODE=OFF
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}${USD_PATH}"
		-DCMAKE_FIND_PACKAGE_PREFER_CONFIG="yes"
		-DPXR_BUILD_ALEMBIC_PLUGIN=$(usex alembic ON OFF)
		-DPXR_BUILD_DOCUMENTATION=$(usex doc ON OFF)
		-DPXR_BUILD_DRACO_PLUGIN=$(usex draco ON OFF)
		-DPXR_BUILD_EMBREE_PLUGIN=$(usex embree ON OFF)
		#-DEMBREE_INCLUDE_DIR=/usr/include/embree4
		-DPXR_BUILD_EXAMPLES=$(usex examples ON OFF)
		-DPXR_BUILD_IMAGING=$(usex imaging ON OFF)
		-DPXR_BUILD_MONOLITHIC=$(usex monolithic ON OFF)
		-DPXR_BUILD_OPENCOLORIO_PLUGIN=$(usex color-management ON OFF)
		-DPXR_BUILD_OPENIMAGEIO_PLUGIN=$(usex openimageio ON OFF)
		-DPXR_BUILD_PRMAN_PLUGIN=OFF
		-DPXR_BUILD_TESTS=$(usex test ON OFF)
		-DPXR_BUILD_TUTORIALS=$(usex tutorials ON OFF)
		-DPXR_BUILD_USD_IMAGING=$(usex imaging ON OFF)
		-DPXR_BUILD_USD_TOOLS=$(usex tools ON OFF)
		-DPXR_BUILD_USDVIEW=$(usex usdview ON OFF)
		-DPXR_ENABLE_GL_SUPPORT=$(usex opengl ON OFF)
		-DPXR_ENABLE_HDF5_SUPPORT=$(usex hdf5 ON OFF)
		-DPXR_ENABLE_MATERIALX_SUPPORT=$(usex materialx)
		-DPXR_ENABLE_OPENVDB_SUPPORT=$(usex openvdb ON OFF)
		-DPXR_ENABLE_OSL_SUPPORT=$(usex osl ON OFF)
		-DPXR_ENABLE_PTEX_SUPPORT=$(usex ptex ON OFF)
		-DPXR_ENABLE_PYTHON_SUPPORT=$(usex python ON OFF)
		-DPXR_ENABLE_VULKAN_SUPPORT=$(usex vulkan ON OFF)
		-DPXR_INSTALL_LOCATION="${EPREFIX}${USD_PATH}"
		-DPXR_PREFER_SAFETY_OVER_SPEED=$(usex safety-over-speed ON OFF)
		-DPXR_PYTHON_SHEBANG="${PYTHON}"
		-DPXR_SET_INTERNAL_NAMESPACE="usdBlender"
		#-DSPIRV_REFLECT_USE_SYSTEM_SPIRV_H=$(usex vulkan ON OFF)
		#-DCMAKE_FIND_DEBUG_MODE=yes
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use usdview && dosym "${USD_PATH}/bin/usdview" /usr/bin/usdview
	dosym "${USD_PATH}"/include/pxr /usr/include/pxr
	echo "${USD_PATH}"/lib >> 99-${PN}.conf || die
	insinto /etc/ld.so.conf.d/
	doins 99-${PN}.conf
	local f
	for f in $(find "${ED}${USD_PATH}/lib" -name "*.so*") ; do
		einfo "Removing rpath from ${f}"
		patchelf --remove-rpath "${f}" || die # triggers warning
	done
	export STRIP="${BROOT}/bin/true" # strip breaks rpath
	if use jemalloc ; then
		for f in $(find "${ED}${USD_PATH}" -executable) ; do
			if ldd "${f}" 2>/dev/null | grep -q -e "libjemalloc.so.2" ; then
				einfo "Changing rpath for ${f} to use jemalloc-usd"
				local old_rpath=$(patchelf --print-rpath "${f}")
				if [[ -n "${old_rpath}" ]] ; then
					old_rpath=":${old_rpath}"
				fi
				patchelf --set-rpath "${EPREFIX}/usr/$(get_libdir)/openusd/$(get_libdir)${old_rpath}" "${f}" || die
			fi
		done

		if [[ -d "${ED}/usr/$(get_libdir)/${PN}/bin" ]] ; then
			mv "${ED}/usr/$(get_libdir)/${PN}/"{bin,.bin} || die
		fi

		local UTILS_LIST=(
			sdffilter
			testusdview
			usdGenSchema
			usdcat
			usdchecker
			usdcompress
			usddiff
			usddumpcrate
			usdedit
			usdrecord
			usdresolve
			usdstitch
			usdstitchclips
			usdtree
			usdview
			usdzip
		)

		# Setting LD_PRELOAD for jemalloc is still required or you may get a segfault
		exeinto /usr/lib64/openusd/bin
		local u
		for u in ${UTILS_LIST[@]} ; do
			if [[ -e "${ED}/usr/$(get_libdir)/${PN}/.bin/${u}" ]] ; then
				einfo "Creating wrapper for ${u}"
				echo -e "#!/bin/bash\nLD_PRELOAD=\"${EPREFIX}/usr/$(get_libdir)/openusd/$(get_libdir)/libjemalloc.so\"" "${EPREFIX}/usr/$(get_libdir)/openusd/.bin/${u}" "\$@" > "${T}/${u}"
				doexe "${T}/${u}"
			fi
		done
	fi
	if use python ; then
		cp -rp "${ED}/usr/lib64/openusd/lib/${EPYTHON}/site-packages/pxr/" \
			"${ED}$(python_get_sitedir)/" || die
		rm -r "${ED}/usr/lib64/openusd/lib/${EPYTHON}/site-packages/pxr"
		# Remove stray python files generated by the build system
		find "${ED}" -name '*.pyc' -exec rm -f {} \; || die
		find "${ED}" -name '*.pyo' -exec rm -f {} \; || die
		python_optimize
	fi
	use doc && einstalldocs
	use usdview && domenu "${FILESDIR}/org.openusd.usdview.desktop"
	use usdview && newicon -s scalable "${FILESDIR}/openusd.svg" "openusd.svg"
	dodoc LICENSE.txt NOTICE.txt
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
