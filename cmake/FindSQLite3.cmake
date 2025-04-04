###############################################################################
# CMake module to search for SQLite 3 library
#
# On success, the macro sets the following variables:
# SQLite3_FOUND = if the library found
# SQLite3_LIBRARY = full path to the library
# SQLite3_LIBRARIES = full path to the library
# SQLite3_INCLUDE_DIR = where to find the library headers
#
# Copyright (c) 2009 Mateusz Loskot <mateusz@loskot.net>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.
#
###############################################################################

find_path(SQLite3_INCLUDE_DIR
  NAMES sqlite3.h
  PATH_PREFIXES sqlite sqlite3
  PATHS
  /usr/include
  /usr/local/include
  $ENV{SQLITE3_HOME}
  $ENV{SQLITE3_HOME}/include
  $ENV{SQLITE3_HOME}/include/sqlite
  $ENV{SQLITE3_HOME}/include/sqlite3
  $ENV{ProgramFiles}/SQLite/*/include
  $ENV{ProgramFiles}/SQLite3/*/include
  $ENV{SystemDrive}/SQLite/*/include
  $ENV{SystemDrive}/SQLite3/*/include)

set(SQLITE3_NAMES sqlite3 sqlite3_s)
find_library(SQLite3_LIBRARY
  NAMES ${SQLITE3_NAMES}
  PATHS
  /usr/lib
  /usr/local/lib
  $ENV{SQLITE3_HOME}
  $ENV{SQLITE3_HOME}/lib
  $ENV{ProgramFiles}/SQLite/*/lib
  $ENV{ProgramFiles}/SQLite3/*/lib
  $ENV{SystemDrive}/SQLite/*/lib
  $ENV{SystemDrive}/SQLite3/*/lib
  ${OSGEO4W_ROOT_DIR}/lib)

set(SQLite3_LIBRARIES ${SQLite3_LIBRARY})

# Handle the QUIETLY and REQUIRED arguments and set SQLite3_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SQLite3
  DEFAULT_MSG
  SQLite3_LIBRARY
  SQLite3_INCLUDE_DIR)

mark_as_advanced(SQLite3_LIBRARY SQLite3_INCLUDE_DIR SQLite3_LIBRARY)
