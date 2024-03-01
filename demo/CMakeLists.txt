cmake_minimum_required(VERSION 3.14)

project(demo
  VERSION 0.1.0
)

include(../cmake/packaging.cmake)
include(../cmake/testing.cmake)

set(TARGET demo)

set(SOURCES
main.cpp
)

set(OBJLIB_SOURCES
calc.cpp
)

add_library(${TARGET}Lib OBJECT ${OBJLIB_SOURCES})
#target_include_directories(${TARGET}Lib PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(${TARGET} ${SOURCES})
target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(${TARGET} PRIVATE $<TARGET_OBJECTS:${TARGET}Lib>)

add_subdirectory(tests)

install(TARGETS ${TARGET} RUNTIME)
