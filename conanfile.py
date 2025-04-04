import os
from conan import ConanFile
from conan.tools.cmake import cmake_layout, CMake, CMakeDeps, CMakeToolchain
from conan.tools.files import apply_conandata_patches, copy, export_conandata_patches


class ExampleRecipe(ConanFile):
    name = "edba"
    homepage = "https://github.com/tarasko/edba"
    description = "Easy database access library"
    topics = "mysql", "odbc", "postgresql", "sqlite3"
    license = "BSL-1.0"
    settings = "os", "compiler", "build_type", "arch"

    options = {
        "shared_core":             [True, False],  # Enable shared versions of core libraries
        "static_core":             [True, False],  # Enable static version of core libraries
        "backends_for_shared":     [True, False],  # Use backends as shared libraries for shared version of core library
        "backends_for_static":     [True, False],  # Use backends as shared libraries for static version of core library
        "with_sqlite3":            [True, False],  # Build backend sqlite3
        "with_odbc":               [True, False],  # Build backend odbc
        "with_oracle":             [True, False],  # Build backend oracle
        "with_mysql":              [True, False],  # Build backend mysql
        "with_postgresql":         [True, False],  # Build backend postgresql
        "enable_tests":            [True, False],  # Add targets for test building. In case of standalone build this would be done always
        "builtin_sqlite3":         [True, False],  # Use sqlite3 amalgamation shipped with edba
        "export_compile_commands": [True, False],  # Export compile_commands.json for clangd
    }

    default_options = {
        "shared_core":             True,
        "static_core":             True,
        "backends_for_shared":     True,
        "backends_for_static":     False,
        "with_sqlite3":            True,
        "with_odbc":               False,
        "with_oracle":             False,
        "with_mysql":              False,
        "with_postgresql":         True,
        "enable_tests":            True,
        "builtin_sqlite3":         False,
        "export_compile_commands": True,
    }

    def export_sources(self):
        export_conandata_patches(self)

    def requirements(self):
        self.requires("boost/1.87.0")
        if self.options.with_sqlite3:
            self.requires("sqlite3/[>=3.8.1 <4]")

    def layout(self):
        cmake_layout(self)

    def generate(self):
        tc = CMakeToolchain(self)
        tc.cache_variables["CMAKE_EXPORT_COMPILE_COMMANDS"] = "ON" if self.options.export_compile_commands else "OFF"
        tc.cache_variables["EDBA_ENABLE_TESTS"] = "ON" if self.options.enable_tests else "OFF"
        tc.cache_variables["EDBA_BACKEND_SQLITE3_DONT_USE_AMALGAMATION"] = "ON" if not self.options.builtin_sqlite3 else "OFF"
        tc.cache_variables["EDBA_BACKEND_SHARED"] = "ON" if self.options.backends_for_shared else "OFF"
        tc.cache_variables["EDBA_S_BACKEND_SHARED"] = "ON" if self.options.backends_for_static else "OFF"
        tc.cache_variables["EDBA_ENABLE"] = "ON" if self.options.shared_core else "OFF"
        tc.cache_variables["EDBA_S_ENABLE"] = "ON" if self.options.static_core else "OFF"
        tc.generate()

        deps = CMakeDeps(self)
        deps.generate()

    def build(self):
        apply_conandata_patches(self)
        cmake = CMake(self)
        cmake.configure()
        cmake.build()

    def package(self):
        copy(self, "LICENSE_1_0.txt", dst=os.path.join(self.package_folder, "licenses"), src=self.source_folder)

        cmake = CMake(self)
        cmake.install()
