# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# @ECLASS: openvdb.eclass
# @MAINTAINER:
# brothermechanic <brothermechanic@gmail.com>
# anex5 <anex5.2008@gmail.com>
# @AUTHOR:
# anex5 <anex5.2008@gmail.com>
# Adrian Grigo <agrigo2001@×××××××××.au>
# Based on work of: Michał Górny <mgorny@g.o> and Krzysztof Pawlik <nelchael@g.o>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: An eclass for OpenVDB to control which ABI version is compiled
# @DESCRIPTION:
# The OpenVDB package is a library for sorting and manipulating sparse
# data structures with dynamic topology as required for use in volume
# rendering for computer graphics.
#
# Each major version of OpenVDB provides an updated ABI, as well as
# the ability to compile using a legacy version of the ABI.
# Openvdb 7 can be compiled to support version 5, 6 or 7 of the ABI.
#
# However the user needs to choose at compile time which version to
# build by passing OPENVDB_ABI_VERSION_NUMBER="5" to cmake.
# It is not possible to support multiple versions concurrently
# so OpenVDB and all packages depending upon it must be built for the
# same ABI version. This currently means blender and openvdb, and
# will also include >=openimageio-2.0 once it is updated
#
# The client packages have differing requirements for the ABI support.
# For example,
# Openvdb-7 supports 5-7 (older version provide ABI 3 and 4 support)
# Blender supports ABI 4-7
# Openimageio-2.0 supports ABI 5-7.
#
# To use this eclass, the user should first select which ABI to build
# and set OPENVDB_ABI USE_EXPAND variable in make.conf.
#
# When the client package inherits this eclass, it can use the
# OPENVDB_COMPAT variable in the ebuild to specify which ABI it
# supports, and then use the OPENVDB_SINGLE_USEDEP variable that the
# eclass produces to force the package to link using ABI selected in
# OPENVDB_ABI
# eg. openvdb? ( media-gfx/openvdb[${OPENVDB_SINGLE_USEDEP}] )
# When OPENVDB_COMPAT="X Y" the variable evaluates to
# abiX-compat(-)? abiY-compat(-)?
#
# The client can pass the ABI version to the build system as follows:
# append-cppflags -DOPENVDB_ABI_VERSION_NUMBER="${OPENVDB_ABI}"
#
# This eclass includes pkg_setup which ensures that the package will
# only compile if only one abiX-compat USE flag is set
#
# @EXAMPLE:
# The user needs to choose which version of the ABI supports all packages
# they plan to install. This is then stored in a variable in make.conf
# eg. OPENVDB_ABI="5" in /etc/portage/make.conf
#
# The client packages need to:
# - inherit this eclass.
# - list the ABI supported by the package in OPENVDB_COMPAT.
# - use OPENVDB_REQUIRED_USE to ensure that only one of the
#   compatible ABI can be selected by the ebuild.
# - include OPENVDB_SINGLE_USEDEP in RDEPEND to ensure any
#   dependencies build against a similar ABI.
# - pass the OPENVDB_ABI version to the package build system
#
# @CODE
# inherit openvdb
# OPENVDB_COMPAT=( 4 5 6 7 )
# REQUIRED_USE="openvdb? ( ${OPENVDB_REQUIRED_USE} )"
# RDEPEND="openvdb? ( media-gfx/openvdb[${OPENVDB_SINGLE_USEDEP}] )"
#
# src_configure() {
#   append-cppflags -DOPENVDB_ABI_VERSION_NUMBER="${OPENVDB_ABI_VERSION}"
#   ...
#   cmake-utils_src_configure
# }
# @CODE
case ${EAPI} in
	7|8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

inherit flag-o-matic

if [[ -z ${_OPENVDB_ECLASS} ]]; then
_OPENVDB_ECLASS=1
# @ECLASS-VARIABLE: OPENVDB_COMPAT
# @REQUIRED
# @DESCRIPTION:
# This variable contains a list of OpenVDB ABI the package supports.
# It must be set before the 'inherit' call and has to be an array.
#
# Example use:
# @CODE
# OPENVDB_COMPAT=( 4 5 6 7 )
# @CODE
#
# @ECLASS-VARIABLE: OPENVDB_SINGLE_USEDEP
# @DESCRIPTION:
# This is an eclass generated USE-dependency flag which can be used by
# any package depending on openvdb to ensure the correct ABI version
# support is built.
#
# Example use:
# @CODE
# RDEPEND="openvdb? ( media-gfx/openvdb[${OPENVDB_SINGLE_USEDEP}] )"
# @CODE
#
# Example value:
# @CODE
# abi3-compat(-)?,abi4-compat(-)?,abi5-compat(-)?...
# @CODE
# @ECLASS-VARIABLE: OPENVDB_REQUIRED_USE
# @DESCRIPTION:
# This is an eclass-generated required use expression which ensures
# that exactly one openvdb_use_X value has been enabled.
#
# Example use:
# @CODE
# REQUIRED_USE="${OPENVDB_REQUIRED_USE}"
# @CODE
#
# Example value:
# @CODE
# ^^ ( abi3-compat abi3-compat abi5-compat abi6-compat abi7-compat )
# @CODE
# @ECLASS-VARIABLE: _OPENVDB_ALL_ABI
# @INTERNAL
# @DESCRIPTION:
# All supported OpenVDB ABI
# Update this with each new major version release of OpenVDB
_OPENVDB_ALL_ABI=( {6..11} )
readonly _OPENVDB_ALL_ABI

# @ECLASS_VARIABLE: OPENVDB_ABI
# @DEFAULT_UNSET
# @DESCRIPTION:
# This variable contains an OpenVDB ABI user want to use
# It must be set in global config such as /etc/portage/make.conf call and has to be a single number.
#
# Example use:
# @CODE
# OPENVDB_ABI=11
# @CODE
: "${OPENVDB_ABI:=}"

# @FUNCTION: _openvdb_set_globals
# @INTERNAL
# @DESCRIPTION:
# Ensure that OPENVDB_COMPAT is valid and generate the
# OPENVDB_REQUIRED_USE and OPENVDB_SINGLE_USEDEP global variables for
# use by the inheriting ebuild
_openvdb_set_globals() {
    local i
    if ! declare -p OPENVDB_COMPAT &>/dev/null; then
        die 'OPENVDB_COMPAT not declared.'
    fi
    if [[ $(declare -p OPENVDB_COMPAT) != "declare -a"* ]]; then
        die 'OPENVDB_COMPAT must be an array.'
    fi
    local flags=()
    for i in "${_OPENVDB_ALL_ABI[@]}"; do
        if has "${i}" "${OPENVDB_COMPAT[@]}"; then
            flags+=( "abi${i}-compat" )
        fi
    done
    if [[ ${#supp[@]} -eq 1 ]]; then
        IUSE="+${flags[0]}"
    else
        IUSE="${flags[*]}"
    fi
    if [[ ! ${#flags[@]} ]]; then
        die "No supported OpenVDB ABI in OPENVDB_COMPAT."
    fi
    local single_flags="${flags[@]/%/(-)?}"
    local single_usedep=${single_flags// /,}
    OPENVDB_REQUIRED_USE="^^ ( ${flags[*]} )"
    OPENVDB_SINGLE_USEDEP="${single_usedep}"
    readonly OPENVDB_REQUIRED_USE OPENVDB_SINGLE_USEDEP
}
_openvdb_set_globals
unset -f _openvdb_set_globals

# @FUNCTION: openvdb_setup
# @DESCRIPTION
# Ensure one and only one OpenVDB ABI version is selected
openvdb_setup() {
    debug-print-function ${FUNCNAME} "${@}"
    local i; local version
    if [[ -z ${OPENVDB_ABI} ]]; then
        eerror "No OpenVDB ABI Version selected for the system. Please set"
        eerror "the OPENVDB_ABI variable in your make.conf to one"
        eerror "of the values contained in all of:"
        eerror
        eerror "- the entire list of ABI: ${_OPENVDB_ALL_ABI[*]}"
        eerror "- the ABI supported by this package: ${OPENVDB_COMPAT[*]}"
        eerror "- and the ABI supported by all other packages on your system"
        echo
        die "No supported OpenVDB ABI version in OPENVDB_ABI."
    fi
    if [[ $(declare -p OPENVDB_ABI) == "declare -a"* ]]; then
        eerror "Your OPENVDB_ABI setting lists more than a single OpenVDB"
        eerror "ABI version. Please set it to just one value."
        echo
        die "More than one ABI in OPENVDB_ABI."
    else
        version="${OPENVDB_ABI}"
        echo "Using OpenVDB ABI ${version} to build"
    fi
}

# @FUNCTION: openvdb_configure
# @DESCRIPTION
# Set cppflags to match selected OpenVDB ABI version
openvdb_configure() {
    debug-print-function ${FUNCNAME} "${@}"
    has_version -b =media-gfx/openvdb-${OPENVDB_ABI} && \
        append-cppflags -DOPENVDB_ABI_VERSION_NUMBER="${OPENVDB_ABI}" || \
        append-cppflags -DOPENVDB_USE_DEPRECATED_ABI_${OPENVDB_ABI}=ON
}

# @FUNCTION: openvdb_pkg_setup
# @DESCRIPTION:
# Runs openvdb_setup.
openvdb_pkg_setup() {
    debug-print-function ${FUNCNAME} "${@}"
    [[ ${MERGE_TYPE} != binary ]] && openvdb_setup
}

# @FUNCTION: openvdb_src_configure
# @DESCRIPTION:
# Runs openvdb_configure.
openvdb_src_configure() {
    debug-print-function ${FUNCNAME} "${@}"
    [[ ${MERGE_TYPE} != binary ]] && openvdb_configure
}

fi

EXPORT_FUNCTIONS src_configure pkg_setup
