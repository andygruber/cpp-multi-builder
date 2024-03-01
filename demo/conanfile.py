import os
from conan import ConanFile, tools
from conan.tools.cmake import CMakeDeps, CMakeToolchain, cmake_layout

class MyConanRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"

    def requirements(self):
        self.requires("gtest/1.14.0")

    def generate(self):
        tc = CMakeToolchain(self)
        tc.cache_variables["CMAKE_INSTALL_PREFIX"] = os.getcwd() + "/../install" # To make sure we have deterministic behavior
        tc.cache_variables["CPACK_OUTPUT_FILE_PREFIX"] = "build/deploy" # Relative to the source folder
        tc.generate()
