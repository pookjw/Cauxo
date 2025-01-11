//
//  CCPTargetResolver.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPTargetResolver.h"

@interface CCPTargetResolver ()
@property (copy, nonatomic, readonly, getter=_handler) void (^handler)(id sender);
@end

@implementation CCPTargetResolver

- (instancetype)initWithHandler:(void (^)(id _Nonnull))handler {
    if (self = [super init]) {
        _handler = [handler copy];
    }
    
    return self;
}

- (void)dealloc {
    [_handler release];
    [super dealloc];
}

- (void)action:(id)sender {
    self.handler(sender);
}

@end
