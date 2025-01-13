//
//  CCPAppSwitcherIconContentConfiguration.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/13/25.
//

#import <UIKit/UIKit.h>
#import "CCPAppSwitcherItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPAppSwitcherIconContentConfiguration : NSObject <UIContentConfiguration>
@property (copy, nonatomic, readonly) CCPAppSwitcherItemModel *itemModel;
@property (assign, nonatomic, readonly, getter=isSelected) BOOL selected;
@property (assign, nonatomic, readonly, getter=isHighlighted) BOOL highlighted;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithItemModel:(CCPAppSwitcherItemModel *)itemModel;
@end

NS_ASSUME_NONNULL_END
