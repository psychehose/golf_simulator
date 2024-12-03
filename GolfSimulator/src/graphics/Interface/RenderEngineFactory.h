#pragma once

#include "RenderEngine.h"
#include <memory>

class IRenderEngineFactory
{
public:
    virtual ~IRenderEngineFactory() = default;
    virtual std::unique_ptr<IRenderEngine> createRenderEngine() = 0;
};

// 플랫폼별 팩토리 생성 함수
std::unique_ptr<IRenderEngineFactory> createRenderEngineFactory();
