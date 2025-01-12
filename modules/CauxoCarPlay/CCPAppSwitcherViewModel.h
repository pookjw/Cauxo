//
//  CCPAppSwitcherViewModel.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import <UIKit/UIKit.h>
#import "CCPAppSwitcherItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CCPAppSwitcherViewModel : NSObject
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataSource:(UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *)dataSource;
- (void)quitProcessForIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
