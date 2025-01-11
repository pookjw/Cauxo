#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#include <signal.h>
#import "ccp+hook.hpp"
#import "CCPAppSwitcherViewController.h"
#import "CCPTargetResolver.h"

namespace ccp_SBIconListView {
namespace initWithModel_layoutProvider_iconLocation_orientation_iconViewProvider_ {
__kindof UIView * (*original)(__kindof UIView *self, SEL _cmd, id model, id layoutProvider, id iconLocation, UIInterfaceOrientation orientation, id iconViewProvider);
__kindof UIView * custom(__kindof UIView *self, SEL _cmd, id model, id layoutProvider, id iconLocation, UIInterfaceOrientation orientation, id iconViewProvider) {
    self = original(self, _cmd, model, layoutProvider, iconLocation, orientation, iconViewProvider);
    
    if (self) {
        CCPTargetResolver *resolver = [[CCPTargetResolver alloc] initWithHandler:^(UITapGestureRecognizer *sender) {
            __kindof UIViewController *_viewControllerForAncestor = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(sender.view, sel_registerName("_viewControllerForAncestor"));
            
            CCPAppSwitcherViewController *switcherViewController = [CCPAppSwitcherViewController new];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:switcherViewController];
            [switcherViewController release];
            
            [_viewControllerForAncestor presentViewController:navigationController animated:YES completion:nil];
            [navigationController release];
        }];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:resolver action:@selector(action:)];
        
        [self addGestureRecognizer:tapGestureRecognizer];
        
        objc_setAssociatedObject(self, resolver, resolver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [resolver release];
    }
    
    return self;
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("SBIconListView"), sel_registerName("initWithModel:layoutProvider:iconLocation:orientation:iconViewProvider:"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}

__attribute__((constructor)) static void init() {
#if DEBUG
    if (static_cast<NSNumber *>(NSProcessInfo.processInfo.environment[@"CCP_WAIT_FOR_DEBUGGER"]).boolValue) {
        kill(getpid(), SIGSTOP);
    }
#endif
    
    ccp_SBIconListView::initWithModel_layoutProvider_iconLocation_orientation_iconViewProvider_::swizzle();
}
