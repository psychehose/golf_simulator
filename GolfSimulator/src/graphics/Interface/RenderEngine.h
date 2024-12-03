#pragma once
#include <cstdint>

class IRenderEngine
{
public:
    virtual ~IRenderEngine() = default;

    // 기본 렌더링 파이프라인
    virtual bool initialize() = 0;
    virtual void cleanup() = 0;
    virtual void beginFrame() = 0;
    virtual void endFrame() = 0;
    virtual void render() = 0;
    virtual void resize(uint32_t width, uint32_t height) = 0;
};
