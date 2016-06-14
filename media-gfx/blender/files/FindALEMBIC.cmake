# - Find Alembic library
# Find the native Alembic includes and libraries
# This module defines
#  ALEMBIC_INCLUDE_DIRS, where to find ALEMBIC headers, Set when
#                        ALEMBIC_INCLUDE_DIR is found.
#  ALEMBIC_LIBRARIES, libraries to link against to use ALEMBIC.
#  ALEMBIC_ROOT_DIR, The base directory to search for ALEMBIC.
#                    This can also be an environment variable.
#  ALEMBIC_FOUND, If false, do not try to use ALEMBIC.
#

#=============================================================================
# Copyright 2016 Blender Foundation.
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================

# If ALEMBIC_ROOT_DIR was defined in the environment, use it.
IF(NOT ALEMBIC_ROOT_DIR AND NOT $ENV{ALEMBIC_ROOT_DIR} STREQUAL "")
  SET(ALEMBIC_ROOT_DIR $ENV{ALEMBIC_ROOT_DIR})
ENDIF()

SET(_alembic_SEARCH_DIRS
  ${ALEMBIC_ROOT_DIR}
  ${HDF5_ROOT_DIR}
  /usr/local
  /sw # Fink
  /opt/local # DarwinPorts
  /opt/csw # Blastwave
  /opt/lib/alembic
)

FIND_PATH(ALEMBIC_INCLUDE_DIR
  NAMES
    Alembic/Abc/All.h
  HINTS
    ${_alembic_SEARCH_DIRS}
  PATH_SUFFIXES
    include
)

FIND_LIBRARY(ALEMBIC_LIBRARY
  NAMES
    Alembic
  HINTS
    ${_alembic_SEARCH_DIRS}
  PATH_SUFFIXES
    lib64 lib
)

FIND_LIBRARY(HDF5_LIBRARY
  NAMES
    hdf5
  HINTS
    ${_alembic_SEARCH_DIRS}
  PATH_SUFFIXES
    lib64 lib
)

# handle the QUIETLY and REQUIRED arguments and set ALEMBIC_FOUND to TRUE if 
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(ALEMBIC DEFAULT_MSG
    ALEMBIC_LIBRARY ALEMBIC_INCLUDE_DIR)

IF(ALEMBIC_FOUND)
  SET(ALEMBIC_LIBRARIES ${ALEMBIC_LIBRARY}
                        ${HDF5_LIBRARY}
                        )

  SET(ALEMBIC_INCLUDE_DIRS ${ALEMBIC_INCLUDE_DIR})
ENDIF(ALEMBIC_FOUND)

MARK_AS_ADVANCED(
  ALEMBIC_INCLUDE_DIR
  ALEMBIC_LIBRARY
)

UNSET(_alembic_SEARCH_DIRS)
