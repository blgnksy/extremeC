cmake_minimum_required(VERSION 3.31)
project(extremeC C)

set(CMAKE_C_STANDARD 23)

set(CMAKE_LINKER_TYPE GOLD)

add_compile_options(-Wall -Wextra -Wpedantic -Wconversion -Wsign-conversion)

#################################
# Generate Docs
#################################
OPTION(BUILD_WITH_DOCS "Generate Docs" ON)
IF(BUILD_WITH_DOCS)
    ADD_SUBDIRECTORY(${CMAKE_CURRENT_SOURCE_DIR}/docs)
ENDIF()


file(GLOB_RECURSE ALL_SOURCE_FILES src/*.cpp include/*.h)

add_custom_target(
        clangformat
        COMMAND /usr/bin/clang-format
        -style=LLVM
        -i
        ${ALL_SOURCE_FILES}
)


add_custom_target(
        cppcheck
        COMMAND /usr/bin/cppcheck
        --enable=warning,performance,portability,information,missingInclude
        --std=c23
        --library=qt.cfg
        --template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
        --verbose
        --quiet
        ${ALL_SOURCE_FILES}
)

add_executable(preproccessors src/preprocessors.c
        src/variable_pointers.c)
add_executable(variable_pointers src/variable_pointers.c)
add_executable(function src/function.c)
add_executable(structs src/structs.c)
add_executable(buffer_overflow src/buffer_overflow.c)
add_executable(stack src/stack.c)
#target_compile_options(stack PRIVATE -O3)
add_executable(heap src/heap.c)
add_executable(heap2 src/heap2.c)
add_executable(cache_friend src/cache_friend.c)
add_executable(c_style_oop src/c_style_oop.c)
add_executable(concurrency src/concurrency.c)
add_executable(getopt src/0000_0_getopt.c)
add_executable(getopt_long src/0000_1_getopt_long.c)
add_executable(0001_0_error_handling src/0001_0_error_handling.c)
add_executable(0002_0_uid_gid src/0002_0_uid_gid.c)
