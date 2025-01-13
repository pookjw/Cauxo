#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#include <signal.h>
#import "ccp+hook.hpp"
#import "CCPAppSwitcherViewController.h"

void *appSwitcherControllerKey = &appSwitcherControllerKey;


namespace ccp_DBDashboard {
namespace _handleHomeEvent_ {
void (*original)(id self, SEL _cmd, id event);
void custom(id self, SEL _cmd, id event) {
    UIWindow *mainWindow = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("mainWindow"));
    UIViewController *rootViewController = mainWindow.rootViewController;
    UIViewController *presentedViewController = rootViewController.presentedViewController;
    
    if (objc_getAssociatedObject(presentedViewController, appSwitcherControllerKey) != nil) {
        [presentedViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        original(self, _cmd, event);
    }
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("DBDashboard"), sel_registerName("_handleHomeEvent:"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}


namespace cpp_DBStatusBarStateProvider {
namespace _radarItemVisible {
BOOL (*original)(id self, SEL _cmd);
BOOL custom(id self, SEL _cmd) {
    return YES;
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("DBStatusBarStateProvider"), sel_registerName("_radarItemVisible"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
namespace _radarItemEnabled {
BOOL (*original)(id self, SEL _cmd);
BOOL custom(id self, SEL _cmd) {
    return YES;
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("DBStatusBarStateProvider"), sel_registerName("_radarItemEnabled"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}


namespace ccp_DBDashboard {
namespace _handleTapToRadarEvent {
void (*original)(id self, SEL _cmd);
void custom(id self, SEL _cmd) {
    __kindof UIApplication *dashboard = UIApplication.sharedApplication;
    id displayManager = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(dashboard, sel_registerName("displayManager"));
    NSDictionary *displayToEnvironmentMap = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(displayManager, sel_registerName("displayToEnvironmentMap"));
    
    for (id display in displayToEnvironmentMap.allKeys) {
        BOOL isCarDisplay = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(display, sel_registerName("isCarDisplay"));
        
        if (isCarDisplay) {
            id environment = displayToEnvironmentMap[display];
            UIWindow *mainWindow = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(environment, sel_registerName("mainWindow"));
            UIViewController *rootViewController = mainWindow.rootViewController;
            UIViewController *presentedViewController = rootViewController.presentedViewController;
            
            if (presentedViewController == nil) {
                CCPAppSwitcherViewController *switcherViewController = [CCPAppSwitcherViewController new];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:switcherViewController];
                [switcherViewController release];
                
                [navigationController setNavigationBarHidden:YES animated:NO];
                
                UISheetPresentationController *sheetPresentationController = navigationController.sheetPresentationController;
                sheetPresentationController.detents = @[
                    [UISheetPresentationControllerDetent customDetentWithIdentifier:nil resolver:^CGFloat(id<UISheetPresentationControllerDetentResolutionContext>  _Nonnull context) {
                        return 170.;
                    }]
                ];
                
                sheetPresentationController.prefersGrabberVisible = YES;
                sheetPresentationController.preferredCornerRadius = 0.;
                sheetPresentationController.prefersEdgeAttachedInCompactHeight = YES;
                reinterpret_cast<void (*)(id, SEL, BOOL)>(objc_msgSend)(sheetPresentationController, sel_registerName("_setWantsFloatingInRegularWidthCompactHeight:"), YES);
                
                objc_setAssociatedObject(navigationController, appSwitcherControllerKey, [NSNull null], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                
                [rootViewController presentViewController:navigationController animated:YES completion:nil];
                [navigationController release];
            } else if (objc_getAssociatedObject(presentedViewController, appSwitcherControllerKey) != nil) {
                [presentedViewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            break;
        }
    }
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("DBDashboard"), sel_registerName("_handleTapToRadarEvent"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}


namespace cpp_UIStatusBarRadarItem {
namespace imageForUpdate_ {
UIImage * (*original)(id self, SEL _cmd, id update);
UIImage * custom(id self, SEL _cmd, id update) {
    return [UIImage systemImageNamed:@"rectangle.stack.fill"];
}
void swizzle() {
    ccp::hookMessage(objc_lookUpClass("_UIStatusBarRadarItem"), sel_registerName("imageForUpdate:"), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}


__attribute__((constructor)) static void init() {
#if DEBUG
    if (static_cast<NSNumber *>(NSProcessInfo.processInfo.environment[@"CCP_WAIT_FOR_DEBUGGER"]).boolValue) {
        kill(getpid(), SIGSTOP);
    }
#endif
    
    assert(dlopen("/System/Library/PrivateFrameworks/SplashBoard.framework/SplashBoard", RTLD_NOW) != NULL);
    
    ccp_DBDashboard::_handleHomeEvent_::swizzle();
    cpp_DBStatusBarStateProvider::_radarItemVisible::swizzle();
    cpp_DBStatusBarStateProvider::_radarItemEnabled::swizzle();
    ccp_DBDashboard::_handleTapToRadarEvent::swizzle();
    cpp_UIStatusBarRadarItem::imageForUpdate_::swizzle();
}
