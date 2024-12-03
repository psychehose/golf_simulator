#pragma once

#import <Foundation/Foundation.h>
#import "../Interface/RenderEngine.h"

// Swift에서 사용할 Objective-C 래퍼 클래스
@interface MetalRenderEngineBridge : NSObject
- (void)initialize;
- (void)cleanup;
- (void)beginFrame;
- (void)endFrame;
- (void)render;
- (void)resize:(uint32_t)width height:(uint32_t)height;
@end

// C++ 인터페이스를 구현하는 Objective-C++ 어댑터
class MetalRenderEngineAdapter : public IRenderEngine
{
private:
    MetalRenderEngineBridge *metalRenderEngine;

public:
    MetalRenderEngineAdapter()
    {
        metalRenderEngine = [[MetalRenderEngineBridge alloc] init];
    }

    ~MetalRenderEngineAdapter()
    {
        metalRenderEngine = nil; // ARC will handle the release
    }

    void initialize() override
    {
        [metalRenderEngine initialize];
    }

    void cleanup() override
    {
        [metalRenderEngine cleanup];
    }

    void beginFrame() override
    {
        [metalRenderEngine beginFrame];
    }

    void endFrame() override
    {
        [metalRenderEngine endFrame];
    }

    void render() override
    {
        [metalRenderEngine render];
    }

    void resize(uint32_t width, uint32_t height) override
    {
        [metalRenderEngine resize:width height:height];
    }
};