cmake_minimum_required(VERSION 3.30)
project(ArregloSist_licoNPU)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)



include_directories(include)

file(GLOB SOURCES "src/*.cpp")


add_executable(ArregloSist_licoNPU ${SOURCES}
        tests/main.cpp
        include/PE.h
        src/PE.cpp
        include/SystolicArray.h
        src/SystolicArray.cpp
        include/Controller.h
        src/Controller.cpp
)


