#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate {
    NSWindow *_window;
    ViewController *_viewController;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSRect screenRect = [[NSScreen mainScreen] frame];
    NSRect windowRect = NSMakeRect(0, 0, screenRect.size.width * 0.8, screenRect.size.height * 0.8);
    
    _window = [[NSWindow alloc] initWithContentRect:windowRect
                                        styleMask:NSWindowStyleMaskTitled |
                                                 NSWindowStyleMaskClosable |
                                                 NSWindowStyleMaskMiniaturizable |
                                                 NSWindowStyleMaskResizable
                                          backing:NSBackingStoreBuffered
                                            defer:NO];
    
    [_window setTitle:@"Golf Simulator"];
    [_window center];
    
    _viewController = [[ViewController alloc] init];
    [_window setContentViewController:_viewController];
    [_window makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
