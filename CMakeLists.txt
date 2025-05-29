cmake_minimum_required(VERSION 3.30)
project(ArregloSist_licoNPU)

set(CMAKE_CXX_STANDARD 20)


include_directories(include)

file(GLOB SOURCES "src/*.cpp")


add_executable(ArregloSist_licoNPU ${SOURCES}
        include/Matrix.h
        src/Matrix.cpp
        include/PE.h
        include/SystolicModel.h
        src/SystolicModel.cpp
        src/Tests.cpp)

add_executable(TestSystolicModel src/Tests.cpp src/Matrix.cpp src/SystolicModel.cpp)

