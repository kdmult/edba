cmake_minimum_required(VERSION 3.17)
project(test_package)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(TARGETS)

add_executable(${PROJECT_NAME} test_package.cpp)
if(TARGET edba)
    target_link_libraries(${PROJECT_NAME} edba)
elseif(TARGET edba_s)
    target_link_libraries(${PROJECT_NAME} edba_s)
endif()
