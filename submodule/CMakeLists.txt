# We put Fortran submodules in their own Git repo because they're such an important Fortran feature.
# Here's an example of using CMake FetchContent

include(FetchContent)

FetchContent_Declare(submodules_proj
  GIT_REPOSITORY https://github.com/scivision/fortran-submodule
  GIT_TAG v1.2.0
)

FetchContent_MakeAvailable(submodules_proj)

add_executable(useext use_ext.f90)
target_link_libraries(useext math_const)
add_test(NAME ExternalSubmodule COMMAND $<TARGET_FILE:useext>)
