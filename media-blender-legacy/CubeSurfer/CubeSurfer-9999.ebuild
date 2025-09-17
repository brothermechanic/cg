# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BLENDER_COMPAT=( 2_93 3_{1..6} 4_{0..5} 5_0 )

PYTHON_COMPAT=( python3_{11..13} )

DISTUTILS_SINGLE_IMPL=1
DISTUTILS_USE_PEP517="no"
DISTUTILS_EXT=1

inherit distutils-r1 blender-addon

DESCRIPTION="IsoSurface mesher addon for Blender (Updated by Gogo)"
HOMEPAGE="https://github.com/porkminer/CubeSurfer"
EGIT_REPO_URI="https://github.com/porkminer/CubeSurfer"

LICENSE="GPL-3"

BDEPEND="$(python_gen_cond_dep '
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/cython[${PYTHON_USEDEP}]
')"

src_prepare() {
	default
	rm -rf "${S}/Releases"
	eapply "${FILESDIR}/${PN}-fix-python-3_11.patch"
	#-e 's/extra_link_args\=\[/extra_link_args\=\['\''-rdynamic'\'', /g' \
	sed -e "s/-O2/${CFLAGS// /\', \'}\', \'-fno-builtin/g" \
		-i "${S}/setup64.py" || die
	distutils-r1_python_prepare_all
}

src_compile() {
	${EPYTHON} setup64.py build_ext --inplace || die "Failed to build mciso.c"
 	for lib in *.cpython-*.so ; do
         local base=${lib##*/}
         ln -s "${base}" "${base%%.*}.so" || die
    done
	rm -rf "${S}/build"
	rm "${S}/mciso.c" "${S}/setup64.py"
}
