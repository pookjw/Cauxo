//
//  da+hook.hpp
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

namespace ccp {
void hookMessage(Class cls, SEL name, BOOL isInstanceMethod, IMP hook, IMP _Nonnull * _Nullable old);
}

NS_ASSUME_NONNULL_END
