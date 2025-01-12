//
//  CCPAppSwitcherItemModel.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherItemModel.h"

@implementation CCPAppSwitcherItemModel

- (instancetype)initWithApplicationInfo:(id)applicationInfo state:(NSUInteger)state {
    if (self = [super init]) {
        _applicationInfo = [applicationInfo retain];
        _state = state;
    }
    
    return self;
}

- (void)dealloc {
    [_applicationInfo release];
    [super dealloc];
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    
    if (![other isKindOfClass:[CCPAppSwitcherItemModel class]]) {
        return NO;
    }
    
    auto casted = static_cast<CCPAppSwitcherItemModel *>(other);
    return [_applicationInfo isEqual:casted->_applicationInfo];
}

- (NSUInteger)hash {
    return [_applicationInfo hash];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    CCPAppSwitcherItemModel *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_applicationInfo = [_applicationInfo retain];
        copy->_state = _state;
    }
    
    return copy;
}

@end
