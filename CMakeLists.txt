cmake_minimum_required(VERSION 3.20)
project(MakcuRelay LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (MSVC)
    # Statically link the MSVC runtime so the second PC
    # does not need a separate VC++ Redistributable installed.
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

add_executable(MakcuRelay
    src/main.cpp
    src/MakcuConnection.cpp
)

target_include_directories(MakcuRelay PRIVATE src)

if (WIN32)
    target_link_libraries(MakcuRelay PRIVATE ws2_32)
endif()
