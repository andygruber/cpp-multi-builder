include(${CMAKE_CURRENT_LIST_DIR}/general.cmake)

if (WIN32)
  set(CPACK_GENERATOR "ZIP")
elseif(DEBIAN)
  set(CPACK_GENERATOR "DEB")
elseif(REDHAT)
  set(CPACK_GENERATOR "RPM")
endif()

if (WIN32)
  set(CPACK_PACKAGING_INSTALL_PREFIX "")
endif()

# Set the package dependencies
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_RPM_PACKAGE_AUTOREQ ON)

set(CPACK_STRIP_FILES ON)

if (NOT CPACK_PACKAGE_CONTACT)
  message(WARNING "CPACK_PACKAGE_CONTACT is not set, using default value")
  set(CPACK_PACKAGE_CONTACT "undefined")
endif()

include(CPack)
