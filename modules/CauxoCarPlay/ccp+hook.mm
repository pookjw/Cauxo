//
//  da+hook.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 3/30/24.
//

#import "ccp+hook.hpp"
#import <objc/runtime.h>
#ifdef USE_ELLEKIT
#if USE_ELLEKIT
#import <substrate.h>
#endif
#endif

void ccp::hookMessage(Class cls, SEL name, BOOL isInstanceMethod, IMP hook, IMP _Nonnull * _Nullable old) {
#ifdef USE_ELLEKIT
#if USE_ELLEKIT
    MSHookMessageEx(cls, name, hook, old);
    return;
#endif
#endif
    
    Method method;
    if (isInstanceMethod) {
        method = class_getInstanceMethod(cls, name);
    } else {
        method = class_getClassMethod(cls, name);
    }
    
    if (old) {
        *old = method_getImplementation(method);
    }
    
    method_setImplementation(method, hook);
}
