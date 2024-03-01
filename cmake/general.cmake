if (${CMAKE_CURRENT_LIST_FILE}_imported)
  return()  # already imported
endif()
set (${CMAKE_CURRENT_LIST_FILE}_imported 1)

# Sets a CMake cache variable with a default value if an environment variable is not defined.
#
# Usage:
#   set_cache_var(VAR_NAME DEF_VAL DESC)
#
# Parameters:
#   VAR_NAME       - The name of the CMake cache variable.
#   DEF_VAL        - The default value to be used if the environment variable is not defined.
#   DESC           - A description for the cache variable.
macro(set_cache_var VAR_NAME DEF_VAL DESC)
  if(NOT DEFINED ENV{${VAR_NAME}})
    set(${VAR_NAME} "${DEF_VAL}" CACHE STRING ${DESC} FORCE)
  else()
    set(${VAR_NAME} "$ENV{${VAR_NAME}}" CACHE STRING ${DESC} FORCE)
  endif()
endmacro()

# get information on Linux based systems about the host OS
# https://stackoverflow.com/questions/55165922/is-there-a-way-to-differentiate-between-fedora-and-centos-on-cmake
function(get_linux_hostos_release_information)
  file(STRINGS /etc/os-release distroname REGEX "^NAME=")
  string(REGEX REPLACE "NAME=\"(.*)\"" "\\1" distroname "${distroname}")
  file(STRINGS /etc/os-release distroid REGEX "^ID=")
  string(REGEX REPLACE "ID=(.*)" "\\1" distroid "${distroid}")
  string(REPLACE "\"" "" distroid "${distroid}")
  file(STRINGS /etc/os-release distroversion REGEX "^VERSION_ID=")
  string(REGEX REPLACE "VERSION_ID=\"(.*)\"" "\\1" distroversion "${distroversion}")

  set(LINUX_DISTRO_NAME "${distroname}" PARENT_SCOPE)
  set(LINUX_DISTRO_ID ${distroid} PARENT_SCOPE)
  set(LINUX_DISTRO_VERSION "${distroversion}" PARENT_SCOPE)
endfunction()

message(STATUS "Checking host OS...")
if ( ${CMAKE_SYSTEM_NAME} STREQUAL Linux )
  get_linux_hostos_release_information()
  message(STATUS "Running on host ${LINUX_DISTRO_NAME} ${LINUX_DISTRO_VERSION} (${LINUX_DISTRO_ID})")
  if ( ${LINUX_DISTRO_ID} STREQUAL sles )
    set(SLES 1)
  elseif ( ${LINUX_DISTRO_ID} STREQUAL ubuntu )
    set(UBUNTU 1)
  elseif ( ${LINUX_DISTRO_ID} STREQUAL debian )
    set(DEBIAN 1)
  elseif ( ${LINUX_DISTRO_ID} STREQUAL rhel OR ${LINUX_DISTRO_ID} STREQUAL centos OR ${LINUX_DISTRO_ID} STREQUAL ol )
    set(REDHAT 1)
  endif()
endif()
