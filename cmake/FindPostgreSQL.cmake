# - Find PostgreSQL
# Find the PostgreSQL includes and client library
# This module defines
#  PostgreSQL_INCLUDE_DIR, where to find libpq-fe.h
#  PostgreSQL_LIBRARIES, libraries needed to use PostgreSQL
#  PostgreSQL_VERSION, if found, version of PostgreSQL
#  PostgreSQL_FOUND, if false, do not try to use PostgreSQL
#
# Copyright (c) 2010, Mateusz Loskot, <mateusz@loskot.net>
# Copyright (c) 2006, Jaroslaw Staniek, <js@iidea.pl>
#
# Redistribution and use is allowed according to the terms of the BSD license.
# For details see the accompanying COPYING-CMAKE-SCRIPTS file.

find_program(PG_CONFIG NAMES pg_config DOC "Path to pg_config utility")

if(PG_CONFIG)
    execute_process(
      COMMAND ${PG_CONFIG} --version
      OUTPUT_VARIABLE PG_CONFIG_VERSION)

    if(${PG_CONFIG_VERSION} MATCHES "^[A-Za-z]+[ ](.*)$")
      string(REGEX REPLACE "^[A-Za-z]+[ ](.*)$" "\\1" PostgreSQL_VERSION "${PG_CONFIG_VERSION}")
    endif()

    execute_process(
      COMMAND ${PG_CONFIG} --includedir
      OUTPUT_VARIABLE PG_CONFIG_INCLUDEDIR)  

    execute_process(
      COMMAND ${PG_CONFIG} --libdir
      OUTPUT_VARIABLE PG_CONFIG_LIBDIR)
else()
  set(PostgreSQL_VERSION "unknown")
endif()

find_path(PostgreSQL_INCLUDE_DIR libpq-fe.h
  ${PG_CONFIG_INCLUDEDIR}
  /usr/include/server
  /usr/include/pgsql/server
  /usr/local/include/pgsql/server
  /usr/include/postgresql
  /usr/include/postgresql/server
  /usr/include/postgresql/*/server
  $ENV{ProgramFiles}/PostgreSQL/*/include
  $ENV{SystemDrive}/PostgreSQL/*/include)

find_library(PostgreSQL_LIBRARIES NAMES pq libpq
  PATHS
  ${PG_CONFIG_LIBDIR}  
  /usr/lib
  /usr/local/lib
  /usr/lib/postgresql
  /usr/lib64
  /usr/local/lib64
  /usr/lib64/postgresql
  $ENV{ProgramFiles}/PostgreSQL/*/lib
  $ENV{SystemDrive}/PostgreSQL/*/lib
  $ENV{ProgramFiles}/PostgreSQL/*/lib/ms
  $ENV{SystemDrive}/PostgreSQL/*/lib/ms)

if(PostgreSQL_INCLUDE_DIR AND PostgreSQL_LIBRARIES)
  set(PostgreSQL_FOUND TRUE)
else()
  set(PostgreSQL_FOUND FALSE)
endif()

# Handle the QUIETLY and REQUIRED arguments and set PostgreSQL_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PostgreSQL
  DEFAULT_MSG
  PostgreSQL_INCLUDE_DIR
  PostgreSQL_LIBRARIES
  PostgreSQL_VERSION)

mark_as_advanced(PostgreSQL_INCLUDE_DIR PostgreSQL_LIBRARIES)
