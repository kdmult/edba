#
# Find the ODBC driver manager includes and library.
#
# ODBC is an open standard for connecting to different databases in a
# semi-vendor-independent fashion.  First you install the ODBC driver
# manager.  Then you need a driver for each separate database you want
# to connect to (unless a generic one works).  VTK includes neither
# the driver manager nor the vendor-specific drivers: you have to find
# those yourself.
#
# This module defines
# ODBC_INCLUDE_DIR, where to find sql.h
# ODBC_LIBRARIES, the libraries to link against to use ODBC
# ODBC_FOUND.  If false, you cannot build anything that requires ODBC.

# also defined, but not for general use is
# ODBC_LIBRARY, where to find the ODBC driver manager library.

set(ODBC_FOUND FALSE)

set(SDK_INCLUDE_PATH
  "C:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/um"
  "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Include"
  "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Include"
  "C:/Program Files/Microsoft SDKs/Windows/v6.0a/Include"
  "C:/Program Files (x86)/Microsoft SDKs/Windows/v6.0/Include"
)

if(CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(SDK_LIB_PATH
    "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.22000.0/um/x86"
    "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Lib"
    "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Lib"
    "C:/Program Files/Microsoft SDKs/Windows/v6.0a/Lib"
    "C:/Program Files (x86)/Microsoft SDKs/Windows/v6.0/Lib"
  )
elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
  set(SDK_LIB_PATH
    "C:/Program Files (x86)/Windows Kits/10/Lib/10.0.22000.0/um/x64"
    "C:/Program Files/Microsoft SDKs/Windows/v7.0A/Lib/x64"
    "C:/Program Files (x86)/Microsoft SDKs/Windows/v7.0A/Lib/x64"
    "C:/Program Files/Microsoft SDKs/Windows/v6.0a/Lib/x64"
    "C:/Program Files (x86)/Microsoft SDKs/Windows/v6.0/Lib/x64"
  )
else()
  message(WARNING "Unsupported architecture: CMAKE_SIZEOF_VOID_P=${CMAKE_SIZEOF_VOID_P}")
endif()

set(PORTABLE_SDK_INCLUDE_PATH "$ENV{SDK_INCLUDE}/um")
set(PORTABLE_SDK_LIB_PATH "$ENV{SDK_LIBS}/um/x64")

find_path(ODBC_INCLUDE_DIR sql.h
  /usr/include
  /usr/include/odbc
  /usr/local/include
  /usr/local/include/odbc
  /usr/local/odbc/include
  "C:/Program Files/ODBC/include"
  ${SDK_INCLUDE_PATH}
  ${PORTABLE_SDK_INCLUDE_PATH}
  "C:/ODBC/include"
  DOC "Specify the directory containing sql.h."
)

find_library(ODBC_LIBRARY
  NAMES iodbc odbc odbcinst odbc32
  PATHS
  /usr/lib
  /usr/lib/odbc
  /usr/local/lib
  /usr/local/lib/odbc
  /usr/local/odbc/lib
  "C:/Program Files/ODBC/lib"
  ${SDK_LIB_PATH}
  ${PORTABLE_SDK_LIB_PATH}
  "C:/ODBC/lib/debug"
  DOC "Specify the ODBC driver manager library here."
  NO_SYSTEM_ENVIRONMENT_PATH
)

set(ODBC_LIBRARIES ${ODBC_LIBRARY})

include(FindPackageHandleStandardArgs)
# handle the QUIETLY and REQUIRED arguments and set ODBC_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(
  ODBC
  DEFAULT_MSG
  ODBC_INCLUDE_DIR ODBC_LIBRARY ODBC_LIBRARIES
)

mark_as_advanced(ODBC_INCLUDE_DIR ODBC_LIBRARY ODBC_LIBRARIES)

