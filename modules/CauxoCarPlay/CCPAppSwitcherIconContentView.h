//
//  CCPAppSwitcherIconContentView.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import <UIKit/UIKit.h>
#import "CCPAppSwitcherIconContentConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPAppSwitcherIconContentView : UIView <UIContentView>
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithConfiguration:(CCPAppSwitcherIconContentConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END
