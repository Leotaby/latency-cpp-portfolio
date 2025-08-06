cmake_minimum_required(VERSION 3.16)
project(ring_buffer_ipc LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(ring_buffer_bench
    src/main.cpp
)

target_include_directories(ring_buffer_bench PRIVATE include)
