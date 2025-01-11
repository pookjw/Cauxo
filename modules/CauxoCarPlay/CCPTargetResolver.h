//
//  CCPTargetResolver.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPTargetResolver : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHandler:(void (^)(id sender))handler;
- (void)action:(id)sender;
@end

NS_ASSUME_NONNULL_END
