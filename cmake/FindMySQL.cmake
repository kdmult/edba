# TODO: Change to use mysqlconfig
# TODO: Check library version

# MYSQL_HOME should point to MySQL connector root

find_path(MySQL_INCLUDE_DIR mysql.h
  $ENV{MySQL_INCLUDE_DIR}
  $ENV{MYSQL_HOME}/include
  /usr/include/mysql
  /usr/local/include/mysql
  /opt/mysql/mysql/include
  /opt/mysql/mysql/include/mysql
  /usr/local/mysql/include
  /usr/local/mysql/include/mysql
  $ENV{ProgramFiles}/MySQL/*/include
  $ENV{SystemDrive}/MySQL/*/include)

if(WIN32)
  # Set lib path suffixes
  # dist = for mysql binary distributions
  # build = for custom built tree
  if(CMAKE_BUILD_TYPE STREQUAL Debug)
    set(libsuffixDist debug)
    set(libsuffixBuild Debug)
  else()
    set(libsuffixDist opt)
    set(libsuffixBuild Release)
    add_definitions(-DDBUG_OFF)
  endif()

  # On Windows, link against dynamic library libmysql, not static mysqlclient
  find_library(MySQL_LIBRARY NAMES libmysql
    PATHS
    $ENV{MYSQL_HOME}/lib/${libsuffixDist}
    $ENV{MYSQL_HOME}/lib/
    $ENV{MYSQL_HOME}/libmysql/${libsuffixBuild}
    $ENV{MYSQL_HOME}/libmysql
    $ENV{MYSQL_HOME}/client/${libsuffixBuild}
    $ENV{MYSQL_HOME}/libmysql/${libsuffixBuild}
    $ENV{ProgramFiles}/MySQL/*/lib/${libsuffixDist}
    $ENV{SystemDrive}/MySQL/*/lib/${libsuffixDist})

else()

  find_library(MySQL_LIBRARY NAMES mysqlclient_r
    PATHS
    $ENV{MYSQL_HOME}/libmysql_r/.libs
    $ENV{MYSQL_HOME}/lib
    $ENV{MYSQL_HOME}/lib/mysql
    /usr/lib/mysql
    /usr/local/lib/mysql
    /usr/local/mysql/lib
    /usr/local/mysql/lib/mysql
    /opt/mysql/mysql/lib
    /opt/mysql/mysql/lib/mysql)
endif()

if(MySQL_LIBRARY)
  get_filename_component(MySQL_LIBRARY_DIR ${MySQL_LIBRARY} PATH)
endif()

if(MySQL_INCLUDE_DIR AND MySQL_LIBRARY_DIR)
  set(MySQL_FOUND TRUE)

  include_directories(${MySQL_INCLUDE_DIR})
  link_directories(${MySQL_LIBRARY_DIR})

  find_library(MySQL_ZLIB zlib PATHS ${MySQL_LIBRARY_DIR})
  find_library(MySQL_YASSL yassl PATHS ${MYyQL_LIBRARY_DIR})
  find_library(MySQL_TAOCRYPT taocrypt PATHS ${MySQL_LIBRARY_DIR})

  if(WIN32)
    set(MYSQL_CLIENT_LIBS mysqlclient)
  else()
    set(MYSQL_CLIENT_LIBS libmysql)
  endif()

  if(MySQL_ZLIB)
    set(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} zlib)
  endif()

  if(MySQL_YASSL)
    set(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} yassl)
  endif()

  if(MySQL_TAOCRYPT)
    set(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} taocrypt)
  endif()

  # Added needed mysqlclient dependencies on Windows
  if(WIN32)
    set(MYSQL_CLIENT_LIBS ${MYSQL_CLIENT_LIBS} ws2_32)
  endif()
endif()

set(MySQL_LIBRARIES ${MySQL_LIBRARY})

# Handle the QUIETLY and REQUIRED arguments and set MySQL_FOUND to TRUE
# if all listed variables are TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MySQL
  DEFAULT_MSG
  MySQL_INCLUDE_DIR
  MySQL_LIBRARIES)

mark_as_advanced(MySQL_INCLUDE_DIR MySQL_LIBRARIES)
