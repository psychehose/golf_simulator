#include "MetalRenderEngineFactory.h"
#include "MetalRenderEngineAdapter.h"


std::unique_ptr<IRenderEngine> MetalRenderEngineFactory::createRenderer() {
    return std::make_unique<MetalRenderEngine>();
}

// Platform-specific factory creation implementation
// 전역 함수

std::unique_ptr<IRenderEngineFactory> createRenderEngineFactory() {
    return std::make_unique<MetalRenderEngineFactory>();
}
