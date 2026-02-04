# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: blender-addon.eclass
# @MAINTAINER:
# brothermechanic <brothermechanic@gmail.com>
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

if [[ ! ${_BLENDER_ADDON_ECLASS} ]]; then
_BLENDER_ADDON_ECLASS=1

PYTHON_COMPAT=( python3_{10..14} )

inherit git-r3 vcs-clean python-single-r1 cg-blender-scripts-dir

# << Eclass variables >>

# @ECLASS_VARIABLE: EGIT_REPO_URI
# @USER_VARIABLE
# @DEFAULT_SET
# @DESCRIPTION:
# Git sources URI for current addon.
: ${EGIT_REPO_URI:="https://projects.blender.org/extensions/${PN}"}

# @ECLASS_VARIABLE: HOMEPAGE
# @USER_VARIABLE
# @DEFAULT_SET
# @DESCRIPTION:
# HOMEPAGE URI for current addon.
: ${HOMEPAGE:="https://extensions.blender.org/add-ons/${PN}"}

# @ECLASS_VARIABLE: _GENTOO_BLENDER_ADDONS_HOME
# @DEFAULT_UNSET
# @INTERNAL
# @DESCRIPTION:
# Each blender slot has it's own subdirectory for addons.
_GENTOO_BLENDER_ADDONS_HOME=()

# @ECLASS_VARIABLE: ADDON_SOURCE_SUBDIR
# @USER_VARIABLE
# @DEFAULT_SET
# @DESCRIPTION:
# Directory within ${S} which contains sources of blender addon.
: ${ADDON_SOURCE_SUBDIR:="${S}/source"}

# @ECLASS_VARIABLE: _BLENDER_ALL_IMPLS
# @INTERNAL
# @DESCRIPTION:
# All possible implementations of blender
_BLENDER_ALL_IMPLS=( 4_{2..5} 5_{0..1} )
readonly _BLENDER_ALL_IMPLS

# @ECLASS_VARIABLE: _BLENDER_SEL_IMPLS
# @INTERNAL
# @DESCRIPTION:
# Currently selected implementations of blender
_BLENDER_SEL_IMPLS=()

# @ECLASS_VARIABLE: BLENDER_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of Blender implementations the package
# supports. It must be set before the `inherit' call. It has to be
# an array.
declare -p BLENDER_COMPAT >/dev/null 2>&1 || BLENDER_COMPAT=( 4_{2..5} 5_{0..1} )

# << Boilerplate ebuild variables >>
: ${DESCRIPTION:="Addon ${PN} for blender"}
: ${SLOT:=0}
: ${KEYWORDS:=alpha amd64 arm arm64 hppa ia64 ~loong m68k ~mips ppc ppc64 ~riscv s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris}
: ${RESTRICT:="mirror test"}
#S="${WORKDIR}/"
RDEPEND+="media-gfx/blender"

# << Phase functions >>
EXPORT_FUNCTIONS pkg_pretend pkg_setup src_install src_compile pkg_postinst pkg_postrm

# @FUNCTION: blender-addon_pkg_pretend
# @DESCRIPTION:
# Performs sanity checks for correct eclass usage, and early-checks.
blender-addon_pkg_pretend() {
	debug-print-function ${FUNCNAME} "${@}"

	for i in "${BLENDER_COMPAT[@]}"; do
		if [[ "${i}" =~ "${_BLENDER_ALL_IMPLS[@]}" ]]; then
			die "Invalid BLENDER_COMPAT : ${BLENDER_COMPAT[@]}"
		fi
	done
}

# @FUNCTION: blender-addon_pkg_setup
# @DESCRIPTION:
# Performs some checks.
blender-addon_pkg_setup() {
	debug-print-function ${FUNCNAME} "${@}"

	[[ ${MERGE_TYPE} != binary ]] && python-single-r1_pkg_setup

	for i in "${BLENDER_COMPAT[@]}"; do
		has_version -r media-gfx\/blender\:${i/_/\.} && _BLENDER_SEL_IMPLS+=( ${i} )
	done

	[[ ${#_BLENDER_SEL_IMPLS[@]} -gt 0 ]] || die "Required Blender version is not installed BLENDER_COMPAT : ( ${BLENDER_COMPAT[@]} )"
}


# @FUNCTION: blender-addon_src_compile
# @DESCRIPTION:
# Nothing to compile here
blender-addon_src_compile() {
	:
}

# @FUNCTION: blender-addon_src_install
# @DESCRIPTION:
# Installs an addon into the CG_BLENDER_SCRIPTS_DIR of default directory
blender-addon_src_install() {
	debug-print-function ${FUNCNAME} "${@}"

	egit_clean
	[[ -a .github ]] && rm -r .github

	for i in "${_BLENDER_SEL_IMPLS[@]}"; do
		_GENTOO_BLENDER_ADDONS_HOME+=( "/usr/share/blender/${i/_/\.}" )
	done

	for (( i = ${#_GENTOO_BLENDER_ADDONS_HOME[@]} - 1; i >= 0; i-- )); do
		python_optimize "${ED}"
		insinto ${_GENTOO_BLENDER_ADDONS_HOME[i]}/extensions/system/${PN}
		diropts -g users -m0775
		doins -r "${ADDON_SOURCE_SUBDIR}"/*
	done
}

# @FUNCTION: blender-addon_pkg_postinst
# @DESCRIPTION:
# output common info after installing blender addon.
blender-addon_pkg_postinst() {
	debug-print-function ${FUNCNAME} "${@}"

	elog "This blender addon installs to following system subdirectory:"
	elog "${_GENTOO_BLENDER_ADDONS_HOME[@]}"
	elog "Each blender slot will use this single directory for the addons."
}

# @FUNCTION: blender-addon_pkg_postrm
# @DESCRIPTION:
# remove addon dir on uninstalling blender addon.
blender-addon_pkg_postrm() {
	if [[ -z "${REPLACED_BY_VERSION}" ]]; then
		for i in "${_BLENDER_SEL_IMPLS[@]}"; do
			_GENTOO_BLENDER_ADDONS_HOME+=( "/usr/share/blender/${i/_/\.}/scripts" )
		done
		for (( i = ${#_GENTOO_BLENDER_ADDONS_HOME[@]} - 1; i >= 0; i-- )); do
			rm -r ${ROOT}${GENTOO_BLENDER_ADDONS_HOME[i]}/addons/${PN}
		done
	fi
}

fi # ${_BLENDER_ADDON_ECLASS}

EXPORT_FUNCTIONS pkg_setup pkg_pretend pkg_postrm pkg_postinst src_compile src_install
