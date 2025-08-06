cmake_minimum_required(VERSION 3.16)
p(market_data_handler LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

add_executable(md_handler_bench
    src/main.cpp
)

target_include_directories(md_handler_bench PRIVATE include)

# Link to any required libraries here (e.g. Boost, rt).
