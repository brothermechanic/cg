# Copyright 2019-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: cg-blender-scripts-dir.eclass
# @MAINTAINER:
# brothermechanic <brothermechanic@gmail.com>
# anex5 <anex5.2008@gmail.com>
# @AUTHOR:
# brothermechanic <brothermechanic@gmail.com>
# @SUPPORTED_EAPIS: 7 8
# @BLURB: An eclass for blender to control default scripts dir
# @DESCRIPTION:
# This eclass is useless

# @ECLASS_VARIABLE: CG_BLENDER_SCRIPTS_DIR
# @USER_VARIABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# Directory for installing blender addons.
# Set empty value for this variable here to install addons to blender default directory according to blender slot
: ${CG_BLENDER_SCRIPTS_DIR:="/usr/share/blender/scripts"}
