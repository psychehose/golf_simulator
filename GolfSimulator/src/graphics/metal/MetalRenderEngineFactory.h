#pragma once

#include "../Interface/RenderEngineFactory.h"

class MetalRenderEngineFactory : public IRenderEngineFactory
{
public:
    std::unique_ptr<IRenderEngine> createRenderEngine() override;
};
