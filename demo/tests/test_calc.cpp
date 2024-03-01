#include "gtest/gtest.h"
#include "calc.h"

// Define a test case for the add function
TEST(AddFunctionTest, HandlesPositiveInput) {
    EXPECT_EQ(add(1, 2), 3);
}

TEST(AddFunctionTest, HandlesNegativeInput) {
    EXPECT_EQ(add(-1, -2), -3);
}

TEST(AddFunctionTest, HandlesMixedInput) {
    EXPECT_EQ(add(-1, 2), 1);
}

// The main function running the tests
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
