//
//  NSDiffableDataSourceSnapshot+CCP_Sort.h
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDiffableDataSourceSnapshot (CCP_Sort)
- (void)ccp_sortItemsWithSectionIdentifiers:(NSArray *)sectionIdentifiers usingComparator:(NSComparator NS_NOESCAPE)cmptr;
- (void)ccp_sortSectionsUsingComparator:(NSComparator NS_NOESCAPE)cmptr;
@end

NS_ASSUME_NONNULL_END
