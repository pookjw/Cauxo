#import <UIKit/UIKit.h>
#import <objc/message.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#include <signal.h>
#import "ccp+hook.hpp"

namespace ccp_UILabel {
namespace setText_ {
void (*original)(UILabel *self, SEL _cmd, NSString *text);
void custom(UILabel *self, SEL _cmd, NSString *text) {
    original(self, _cmd, @"Foo!");
}
void swizzle() {
    ccp::hookMessage([UILabel class], @selector(setText:), YES, reinterpret_cast<IMP>(custom), reinterpret_cast<IMP *>(&original));
}
}
}

__attribute__((constructor)) static void init() {
    ccp_UILabel::setText_::swizzle();
#if DEBUG
    if (static_cast<NSNumber *>(NSProcessInfo.processInfo.environment[@"CCP_WAIT_FOR_DEBUGGER"]).boolValue) {
        kill(getpid(), SIGSTOP);
    }
#endif
}
