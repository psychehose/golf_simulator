cmake_minimum_required(VERSION 3.14...3.28)

# 컴파일러 설정
if(WIN32)
    set(CMAKE_CXX_COMPILER "clang-cl")
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4 /EHsc")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /Zi /Od /MDd")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /O2 /MD")
else()
    set(CMAKE_CXX_COMPILER "clang++")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -Wall -Wextra")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -O0")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

#
# FetchContent 모듈을 포함시킵니다.
# 이 모듈은 외부 프로젝트를 다운로드하고 빌드하는 기능을 제공합니다.
# 라이브러리의 의존성을 자동으로 관리할 수 있게 해줍니다.

project(GolfSimulator)

include(FetchContent)

FetchContent_Declare(SFML
    GIT_REPOSITORY https://github.com/SFML/SFML.git
    GIT_TAG 3.0.0
    GIT_SHALLOW ON
    EXCLUDE_FROM_ALL
    SYSTEM
)

FetchContent_MakeAvailable(SFML)

# 빌드 타입에 따라 출력 디렉토리 설정
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
else()
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
endif()


set(SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/core/GolfBall.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/core/Simulator.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/main.cpp
)
set(HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/core/GolfBall.h
    ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/core/Simulator.h
)

add_executable(${PROJECT_NAME} ${SOURCES} ${HEADERS})

target_include_directories(${PROJECT_NAME} 
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src
        ${CMAKE_CURRENT_SOURCE_DIR}/GolfSimulator/src/core
)

target_link_libraries(${PROJECT_NAME}
    PRIVATE
        SFML::Graphics
        SFML::Window
        SFML::System
)