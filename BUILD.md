# Build Environment Setup Guide

With the help of examples, this section guides you through the process of initializing a build environment for C++ projects with or without using the Conan package manager, focusing on setting up for different build types such as Debug, Release, and RelWithDebInfo.

## Conan

If you are using conan for managing dependencies, it is recommended to also define install and packaging paths in the `conanfile.py`. The build examples in that chapter assume this is the case.

```python
import os
from conan import ConanFile, tools
from conan.tools.cmake import CMakeDeps, CMakeToolchain, cmake_layout

class MyConanRecipe(ConanFile):
    settings = "os", "compiler", "build_type", "arch"
    generators = "CMakeDeps"

    def requirements(self):
        self.requires("gtest/1.14.0")
        # Example to add conditional requirements for certain OS
        # if self.settings.os == "Windows":
        #     self.requires("openssl/3.0.13")

    # do not change these directories to other values to maintain compatibility
    # with the build automation
    def generate(self):
        tc = CMakeToolchain(self)
        tc.cache_variables["CMAKE_INSTALL_PREFIX"] = os.getcwd() + "/../install" # To make sure we have deterministic behavior
        tc.cache_variables["CPACK_OUTPUT_FILE_PREFIX"] = "build/deploy"
        tc.generate()
```

### Visual Studio Solution

```cmd
rem change to the directory of the CMakeLists.txt
cd demo

rem set the build directory
set BUILDDIR=build/make

rem remove the build directory and recreate it
rmdir /Q/S build
md build

rem detect the conan profile, only need to run once
conan profile detect

rem install the dependencies using conan for the different build types
conan install . --output-folder=%BUILDDIR% --profile ../config/conan/win_msvc2022vc143.txt --build=missing -s build_type=Debug
conan install . --output-folder=%BUILDDIR% --profile ../config/conan/win_msvc2022vc143.txt --build=missing -s build_type=Release
conan install . --output-folder=%BUILDDIR% --profile ../config/conan/win_msvc2022vc143.txt --build=missing -s build_type=RelWithDebInfo

rem create Visual Studio solution and open it in Visual Studio
cmake --preset conan-default
start %BUILDDIR%/demoDrv.sln

rem build/install/package/test from the command line
cmake --build %BUILDDIR% --config RelWithDebInfo
cmake --install %BUILDDIR% --config RelWithDebInfo
cpack -V --config %BUILDDIR%/CPackConfig.cmake -C RelWithDebInfo
ctest -V --test-dir %BUILDDIR% --output-on-failure -C RelWithDebInfo
```

### Ninja on Windows

```cmd
rem change to the directory of the CMakeLists.txt
cd demo

rem set the build directory
set BUILDDIR=build/make

rem remove the build directory and recreate it
rmdir /Q/S build
md build

rem detect the conan profile, only need to run once
conan profile detect

rem install the dependencies using conan for RelWithDebInfo
conan install . --output-folder=%BUILDDIR% --build=missing --profile=../config/conan/win_msvc2022vc143.txt -s build_type=RelWithDebInfo -c tools.cmake.cmaketoolchain:generator=Ninja

rem Conan creates the correct VCvars script, init with this
call "%BUILDDIR%/conanvcvars.bat"

rem open the source so in Visual Studio Code and use the generated cmake-presets there
code .

rem alternative do everything on the commandline
cmake --preset conan-relwithdebinfo

rem build/install/package/test from the command line
cmake --build %BUILDDIR%
cmake --install %BUILDDIR%
cpack -V --config %BUILDDIR%/CPackConfig.cmake
ctest -V --test-dir %BUILDDIR% --output-on-failure
```

### Ninja on Linux

```bash
# change to the directory of the CMakeLists.txt
cd demo

# set the build directory
export BUILDDIR=build/make

# remove the build directory and recreate it
rm -rf build
mkdir build

# detect the conan profile, only need to run once
conan profile detect

# install the dependencies using conan for RelWithDebInfo
# we already are on the target platform in a (dev)container, so no profile needed
conan install . --output-folder=${BUILDDIR} --build=missing -s build_type=RelWithDebInfo -c tools.cmake.cmaketoolchain:generator=Ninja

# open the source so in Visual Studio Code and use the generated cmake-presets there
code .

# alternative do everything on the commandline
cmake --preset conan-relwithdebinfo

rem build/install/package/test from the command line
cmake --build ${BUILDDIR}
cmake --install ${BUILDDIR}
cpack -V --config ${BUILDDIR}/CPackConfig.cmake
ctest -V --test-dir ${BUILDDIR} --output-on-failure
```
