#import "ViewController.h"
// #import "graphics/metal/MetalRenderEngineAdapter.h"
// #import "graphics/Interface/RenderEngineFactory.h"

// @interface ViewController () <MTKViewDelegate>
// @property (nonatomic, strong) MTKView *metalView;
// @property (nonatomic, assign) IRenderEngine *renderEngine;
// @end

@implementation ViewController

- (void)loadView {
    self.view = [[NSView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // // Metal 뷰 설정
    // self.metalView = [[MTKView alloc] initWithFrame:self.view.bounds];
    // self.metalView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    // [self.view addSubview:self.metalView];
    
    // // 렌더 엔진 생성
    // IRenderEngineFactory* factory = CreateMetalRenderEngineFactory();
    // self.renderEngine = factory->CreateRenderEngine((__bridge void*)self.metalView);
    // self.renderEngine->initialize();
    
    // // 뷰 델리게이트 설정
    // self.metalView.delegate = self;
}

- (void)dealloc {
    // if (self.renderEngine) {
    //     self.renderEngine->cleanup();
    //     delete self.renderEngine;
    // }
}

#pragma mark - MTKViewDelegate

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
    // self.renderEngine->resize(size.width, size.height);
}

- (void)drawInMTKView:(MTKView *)view {
    // self.renderEngine->beginFrame();
    // self.renderEngine->render();
    // self.renderEngine->endFrame();
}

@end
