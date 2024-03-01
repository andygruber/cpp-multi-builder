set(SOURCES
test_calc.cpp
)

add_gtest_with_xml(${TARGET} ${TARGET}Lib ${SOURCES})
