cmake_minimum_required(VERSION 3.20)

# 언어 설정
enable_language(OBJC)
enable_language(OBJCXX)
enable_language(Swift)

#core
set(CORE_SOURCES
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/core/GolfBall.cpp
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/core/GolfBall.hpp
)

# Graphics - not swift
set(GRAPHICS_SOURCES
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/metal/MetalRenderEngineAdapter.h
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/metal/MetalRenderEngineFactory.h
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/metal/MetalRenderEngineFactory.mm
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/Interface/RenderEngine.h
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/Interface/RenderEngineFactory.h
)

# Swift 소스 파일 목록 and Graphics swift
set(SWIFT_SOURCES
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/metal/MetalRenderEngine.swift
    ${CMAKE_SOURCE_DIR}/GolfSimulator/src/graphics/metal/Camera/Camera.swift
)

# PLATFORM / MAC
set(PLATFORM_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/main.mm
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AppDelegate.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/AppDelegate.mm
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ViewController.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/ViewController.mm
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GolfBallBridge.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/GolfBallBridge.mm
)


# Xcode 설정
set(CMAKE_XCODE_GENERATE_SCHEME TRUE)
set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES)
set(CMAKE_XCODE_ATTRIBUTE_SWIFT_VERSION 5.0)
set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE NO)
set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH YES)


# Mac 앱 타겟 설정
add_executable(GolfSimulatorApp MACOSX_BUNDLE
    ${CORE_SOURCES}
    ${GRAPHICS_SOURCES}
    ${PLATFORM_SOURCES}
    ${SWIFT_SOURCES}
)

# Swift 컴파일 옵션
set_target_properties(GolfSimulatorApp PROPERTIES
    XCODE_ATTRIBUTE_SWIFT_OBJC_BRIDGING_HEADER "${CMAKE_SOURCE_DIR}/GolfSimulator/platform/mac/src/GolfSimulatorApp-Bridge-Header.h"
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/../Frameworks"
    XCODE_ATTRIBUTE_SWIFT_OBJC_INTERFACE_HEADER_NAME "GolfSimulatorApp-Swift.h"
    XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES
    RESOURCE "${METAL_SOURCES}" # 추후 수정
)

# 프레임워크 링크
target_link_libraries(GolfSimulatorApp PRIVATE
    "-framework Cocoa"
    "-framework Metal"
    "-framework MetalKit"
    "-framework QuartzCore"
)

# 헤더 경로 설정
target_include_directories(GolfSimulatorApp PRIVATE
    ${CMAKE_SOURCE_DIR}/GolfSimulator/core/src
    ${CMAKE_SOURCE_DIR}/GolfSimulator/platform/mac/src
    ${CMAKE_SOURCE_DIR}/GolfSimulator/graphics/src
)

# 번들 설정
set_target_properties(GolfSimulatorApp PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.example.GolfSimulator"
    MACOSX_BUNDLE_BUNDLE_NAME "GolfSimulator"
    MACOSX_BUNDLE_BUNDLE_VERSION "1.0"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    
    # Xcode specific settings
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.example.GolfSimulator"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
    XCODE_ATTRIBUTE_DEVELOPMENT_TEAM ""
    XCODE_ATTRIBUTE_ENABLE_HARDENED_RUNTIME YES
)
