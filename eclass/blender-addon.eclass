# Copyright 2019-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: blender-addon.eclass
# @MAINTAINER:
# cg <>
# anex5 <anex5.2008@gmail.com>
# @AUTHOR:
# anex5 <anex5.2008@gmail.com>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: Eclass used to create and maintain blender addons
# @DESCRIPTION:
# This eclass represents and creates an addon for blender.
# Additional variables are provided to override the default directory
# for blender addons.

case "${EAPI:-0}" in
	[0-5]) die "Unsupported EAPI=${EAPI:-0} (too old) for ${ECLASS}" ;;
	[6-8]) ;;
	*)     die "Unsupported EAPI=${EAPI} (unknown) for ${ECLASS}" ;;
esac

PYTHON_COMPAT=( python3_{9..11} )

inherit git-r3 vcs-clean python-single-r1

# << Eclass variables >>

# @ECLASS_VARIABLE: GENTOO_BLENDER_ADDONS_DIR
# @DEFAULT_UNSET
# @DESCRIPTION:
# Base directory for installing blender addons
: ${GENTOO_BLENDER_ADDONS_DIR:=}

# @ECLASS_VARIABLE: _BLENDER_ALL_IMPLS
# @DESCRIPTION:
# All possible implementations of blender
_BLENDER_ALL_IMPLS=( 2_93 3_{1..6} )
readonly _BLENDER_ALL_IMPLS

# @ECLASS_VARIABLE: _BLENDER_ALL_IMPLS
# @DESCRIPTION:
# All possible implementations of blender
_BLENDER_SEL_IMPL=

# @ECLASS_VARIABLE: BLENDER_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of Blender implementations the package
# supports. It must be set before the `inherit' call. It has to be
# an array.

# << Boilerplate ebuild variables >>
: ${DESCRIPTION:="Addon ${PN} for blender"}
: ${SLOT:=0}
: ${KEYWORDS:=alpha amd64 arm arm64 hppa ia64 ~loong m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris}
: ${RESTRICT:="mirror"}
#S="${WORKDIR}/"
RDEPEND="media-gfx/blender:="

# << Phase functions >>
EXPORT_FUNCTIONS pkg_pretend src_install src_compile pkg_postinst pkg_postrm

# @FUNCTION: get_blender_impl
# @DESCRIPTION:
get_blender_impl ()
{
	for i in "${BLENDER_COMPAT[@]}"; do
		has_version -r media-gfx\/blender\:${i/_/\.} && _BLENDER_SEL_IMPL=${i/_/\.}
	done

    echo "${_BLENDER_SEL_IMPL}"
}

# @FUNCTION: blender-addon_pkg_pretend
# @DESCRIPTION:
# Performs sanity checks for correct eclass usage, and early-checks.
blender-addon_pkg_pretend() {
	debug-print-function ${FUNCNAME} "${@}"

	for i in "${BLENDER_COMPAT[@]}"; do
		if ! has "${i}" "${_BLENDER_ALL_IMPLS[@]}"; then
			die "Invalid BLENDER_COMPAT : ${BLENDER_COMPAT[@]}"
		fi
	done

	[[ -z $(get_blender_impl) ]] && eerror "Required Blender version is not installed BLENDER_COMPAT : ( ${BLENDER_COMPAT[@]} )" && die
}

# @FUNCTION: blender-addon_src_compile
# @DESCRIPTION:
# Nothing to compile here
blender-addon_src_compile() {
	:
}

# @FUNCTION: blender-addon_src_install
# @DESCRIPTION:
# Installs an addon into the GENTOO_BLENDER_ADDONS_DIR directory
blender-addon_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	: ${GENTOO_BLENDER_ADDONS_DIR:="/usr/share/blender/$(get_blender_impl)/scripts"}

	egit_clean
	[[ -a .github ]] && rm -r .{github}
	insinto ${GENTOO_BLENDER_ADDONS_DIR}/addons/${PN}
	diropts -g users -m0775
	doins -r "${S}"/*
	python_optimize "${D}${GENTOO_BLENDER_ADDONS_DIR}/addons/${PN}"
}

# @FUNCTION: blender-addon_pkg_postinst
# @DESCRIPTION:
# output common info after installing blender addon.
blender-addon_pkg_postinst() {
	debug-print-function ${FUNCNAME} "${@}"

	elog
	elog "This blender addon installs to following system subdirectory"
	elog "${GENTOO_BLENDER_ADDONS_DIR}"
	elog "You can override this value by setting GENTOO_BLENDER_ADDONS_DIR to your make.conf file"
	elog "Please, set this value to PreferencesFilePaths.scripts_directory"
	elog "More info you can find at page "
	elog "https://docs.blender.org/manual/en/latest/preferences/file.html#scripts-path"
	elog
}

# @FUNCTION: blender-addon_pkg_postrm
# @DESCRIPTION:
# remove addon dir on uninstalling blender addon.
blender-addon_pkg_postrm() {
	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		rm -r ${ROOT}${GENTOO_BLENDER_ADDONS_DIR}/addons/${PN}
	fi
}
