# C++ Multi Builder

This GitHub repository provides a ready-to-use GitHub Action to build C++ projects.
It is designed to lower the entry barrier for developers and allow easy building, unit testing, and packaging of C++ projects for multiple combinations of OS using a single C++ source code.

## Features

- **Ease of Use**: Set up with minimal configuration required.
- **Multiple OS Support**: Build your C++ projects for various combinations of operating systems.
- **C++ Package Manager Support**: Conan package manager is supported out of the box for managing C++ dependencies.
- **Automated Testing and Packaging**: Includes support for unit testing and packaging of your projects.
- **Debug files available**: PDB and unstripped files are kept beside the build artifacts.
- **Caching Support**: Conan packages are cached automatically

## Getting Started

### Prerequisites

- A GitHub account
- Basic knowledge of C++ and CMake
- Familiarity with GitHub Actions

### Fork the Repository

To get started, fork this repository to your own GitHub account. This will be the home for your C++ CMake project.

### Initial general configuration

The default configuration is saved in `pipeline/createMatrix/mergekeys.yml`.

In this file the used Docker images and various other settings are stored.

#### Linux

Linux builds rely on Docker images.

Those docker images need to have the following tools installed:
- compiler
- ninja
- conan

### Add Your C++ CMake Project

Place your C++ source code anywhere in the repository alongside a `CMakeLists.txt` file.
This is where you'll define your project and its dependencies.

### Configuration

Create a `build-config.yml` file in your repository alongside the `CMakeLists.txt`.
This file specifies the build configurations for different OS.
Here's an example based on the provided demo in the `demo`directory:

```yaml
demo:
  configuration:
    win_msvc2022vc142_relwithdebinfo:
      <<: *_win_msvc2022vc142_relwithdebinfo
    win_msvc2022vc143_relwithdebinfo:
      <<: *_win_msvc2022vc143_relwithdebinfo
    debian_bookworm_relwithdebinfo:
      <<: *_debian_bookworm_relwithdebinfo
    debian_bullseye_relwithdebinfo:
      <<: *_debian_bullseye_relwithdebinfo
```

For C++ package management, create a `conanfile.txt` or `conanfile.py` file alongside your `CMakeLists.txt`.

### Utilize Packaging and Testing

To use unit testing and/or packaging, include the necessary CMake files for packaging and testing as follows:
```cmake
project(demo
  VERSION 0.1.0
)
# make sure to place the include commands after the project
# command specifying the project name and version
include(../cmake/packaging.cmake)
include(../cmake/testing.cmake)
```

These includes will enable the GitHub Action pipeline to perform automated testing and packaging of your project.

Testing also requires the [googletest](https://github.com/google/googletest) framework, just merge the following line into your `conanfile.py`:
```python
    def requirements(self):
        self.requires("gtest/1.14.0")
```

A full example of a `conanfile.py` can be found [here](BUILD.md#conan).

### Details about packaging

#### Key Features

Automatically selects packaging format based on the target OS.
- **Windows**: Packages are generated as ZIP files.
- **Debian-based Linux**: Packages are generated as DEB files.
- **Red Hat-based Linux**: Packages are generated as RPM files.

#### Customization

Beside the mentioned [Key features](#key-features) CPack default features are used.

For Linux it is recommended to set the `CPACK_PACKAGING_INSTALL_PREFIX` to whatever is desired. E.g.:

```cmake
set(CPACK_PACKAGING_INSTALL_PREFIX "/usr/local/bin/")
```

For additional customization, such as including additional files in the package or changing package metadata, refer to the [CPack documentation](https://cmake.org/cmake/help/latest/module/CPack.html).

### How to Add a New Test

1. **Define Test Sources:**
List all source files associated with your test.
For a comprehensive test suite, you might separate your test sources from your main application sources.

2. **Use the `add_gtest_with_xml` Macro:**
This macro is used to compile the test sources into an executable, link it against Google Test and any necessary project libraries, and set up XML output for test results.
The basic syntax is:

   ```cmake
   add_gtest_with_xml(TARGET_NAME TARGET_LIBRARY TEST_SOURCES)
   ```

   - `TARGET_NAME`: A unique name for your test executable.
   - `TARGET_LIBRARY`: The library against which your test executable should be linked. This usually includes your project's main library.
   - `TEST_SOURCES`: The source files for your test.

3. **Example:**
For a hypothetical binary named `demo` that tests functionality in `demoLib`, you might write:

   ```cmake
   set(TEST_SOURCES demoTest.cxx)
   add_gtest_with_xml(demo demoLib ${TEST_SOURCES})
   ```

4. **Integration with CMakeLists.txt:**
Add your test configuration to a `CMakeLists.txt` within your project's test directory.
If your project structure does not already include a test directory, create one as shown:

   ```cmake
   add_subdirectory(tests)
   ```

### Build Pipeline

The `build.yml` GitHub Action workflow file orchestrates the build process.
It prepares the build environment, installs necessary dependencies, and runs the build according to configurations specified in `build-config.yml`.
This process is triggered by push or pull request events to the main branch, or can be manually dispatched.

When running the build, certain directories are set automatically:
- **build directory:** is set set to `build/make`
- **install dir:** is set to `build/install` via `CMAKE_INSTALL_PREFIX` cache variable
- **packaging dir:** is set to `build/deploy` via `CPACK_OUTPUT_FILE_PREFIX` cache variable

**Note:** The automation searchs in these paths for the build artifacts, like test results or the generated binaries.
When doing modifications, please make sure those directories are still be set correctly by the automation.

#### Docker login

If you use private container images, uncomment the following lines in `build.yml` and provide the referenced secrets.

```yaml
      # credentials:
      #   username: ${{ secrets.DOCKERHUB_USER}}
      #   password: ${{ secrets.DOCKERHUB_PASSWORD}}
```

## Local Build Environment Setup

For detailed instructions on setting up your local build environment, including configuring Conan and CMake for various build types, please see the [Build Environment Setup Guide](BUILD.md).
This guide provides step-by-step instructions to help you get started quickly and efficiently.

## Support

For any questions or support, consider opening an issue in the repository. Contributions to improve the build process or add new features are welcome.
