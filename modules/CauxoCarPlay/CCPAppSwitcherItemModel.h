//
//  CCPAppSwitcherItemModel.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CCPAppSwitcherItemModel : NSObject <NSCopying>
@property (retain, nonatomic, readonly) id applicationInfo;
@property (assign, nonatomic, readonly) NSUInteger state;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithApplicationInfo:(id)applicationInfo state:(NSUInteger)state;
@end

NS_ASSUME_NONNULL_END
