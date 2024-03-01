# Define a macro with the name 'add_gtest_with_xml' that takes three parameters: TARGET, TARGET_LIB and SOURCES
# TARGET is the target name which runs the original code
# TARGET_LIB is the name of the linked library which contains all production code and is also linked by TARGET
# the test target is called 'test_${TARGET}' automatically and also links to TARGET_LIB
# Usage:
# set(MY_SOURCES source1.cpp source2.cpp source3.cpp)
# add_gtest_with_xml(MyTarget MyTargetLib "${MY_SOURCES}")
macro(add_gtest_with_xml TARGET TARGET_LIB SOURCES )

  # Formulate the test target name
  set(TESTTARGET test_${TARGET})
  
  # Define the executable for the test using the provided SOURCES
  add_executable(${TESTTARGET} ${SOURCES})

  # Determine the XML file path for test results
  set(XMLFILE "${CMAKE_CURRENT_BINARY_DIR}/c${TESTTARGET}.xml")

  # Retrieve the linked libraries from the original target and apply them to the test target
  get_target_property(${TARGET}_LINKLIBS ${TARGET} LINK_LIBRARIES)
  set_target_properties(${TESTTARGET} PROPERTIES LINK_LIBRARIES "${${TARGET}_LINKLIBS}")

  # Retrieve the include directories from the original target and apply them to the test target
  get_target_property(${TARGET}_INCLUDES ${TARGET} INCLUDE_DIRECTORIES)
  if(NOT "${${TARGET}_INCLUDES}" STREQUAL "${TARGET}_INCLUDES-NOTFOUND")
    set_target_properties(${TESTTARGET} PROPERTIES INCLUDE_DIRECTORIES "${${TARGET}_INCLUDES}")
  endif()

  # Link the necessary libraries with the test target
  target_link_libraries(${TESTTARGET}
    PRIVATE
    GTest::gtest_main
    $<TARGET_OBJECTS:${TARGET_LIB}>)

  # Add the test executable to CTest with a custom command for XML output
  add_test(NAME ${TESTTARGET} COMMAND ${TESTTARGET} --gtest_output=xml:${XMLFILE})
  
  # Pre-write to the XML file with a default content indicating a failure scenario. This ensures the file exists.
  file(WRITE ${XMLFILE} "<?xml version=\"1.0\" encoding=\"UTF-8\"?><testsuites><testsuite name=\"${TESTTARGET}\" tests=\"1\" errors=\"1\"><testcase name=\"${TARGET}\" classname=\"[Crash]\"><error>The executable did not shutdown orderly and no result xml was written. This means that the test has either crashed or called exit/abort/terminate</error></testcase></testsuite></testsuites>")

endmacro()

if (CUSTOMENABLEINCLUDE_GTEST)
  return()
endif()

find_package(GTest REQUIRED)
enable_testing()
