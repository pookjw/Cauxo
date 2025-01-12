//
//  CCPAppSwitcherViewController.m
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherViewController.h"
#import <objc/message.h>
#import <objc/runtime.h>
#import "CCPAppSwitcherViewModel.h"
#import "CCPAppSwitcherIconContentView.h"

@interface CCPAppSwitcherViewController () <UICollectionViewDelegate>
@property (retain, nonatomic, readonly, getter=_doneBarButtonItem) UIBarButtonItem *doneBarButtonItem;
@property (retain, nonatomic, readonly, getter=_collectionView) UICollectionView *collectionView;
@property (retain, nonatomic, readonly, getter=_dataSource) UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *dataSource;
@property (retain, nonatomic, readonly, getter=_cellRegistration) UICollectionViewCellRegistration *cellRegistration;
@property (retain, nonatomic, readonly, getter=_viewModel) CCPAppSwitcherViewModel *viewModel;
@end

@implementation CCPAppSwitcherViewController
@synthesize doneBarButtonItem = _doneBarButtonItem;
@synthesize collectionView = _collectionView;
@synthesize dataSource = _dataSource;
@synthesize cellRegistration = _cellRegistration;
@synthesize viewModel = _viewModel;

- (void)dealloc {
    [_doneBarButtonItem release];
    [_collectionView release];
    [_dataSource release];
    [_cellRegistration release];
    [_viewModel release];
    [super dealloc];
}

- (void)loadView {
    self.view = self.collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _viewModel];
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
}

- (UIBarButtonItem *)_doneBarButtonItem {
    if (auto doneBarButtonItem = _doneBarButtonItem) return doneBarButtonItem;
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_didTriggerDoneBarButtonItem:)];
    
    _doneBarButtonItem = doneBarButtonItem;
    return doneBarButtonItem;
}

- (UICollectionView *)_collectionView {
    if (auto collectionView = _collectionView) return collectionView;
    
    UICollectionViewCompositionalLayoutConfiguration *configuration = [UICollectionViewCompositionalLayoutConfiguration new];
    configuration.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionViewCompositionalLayout *collectionViewLayout = [[UICollectionViewCompositionalLayout alloc] initWithSectionProvider:^NSCollectionLayoutSection * _Nullable(NSInteger sectionIndex, id<NSCollectionLayoutEnvironment>  _Nonnull layoutEnvironment) {
        NSCollectionLayoutSize *itemSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.25]
                                                                          heightDimension:[NSCollectionLayoutDimension fractionalHeightDimension:1.]];
        
        NSCollectionLayoutItem *item = [NSCollectionLayoutItem itemWithLayoutSize:itemSize supplementaryItems:@[]];
        
        NSCollectionLayoutSize *groupSize = [NSCollectionLayoutSize sizeWithWidthDimension:[NSCollectionLayoutDimension fractionalWidthDimension:1.]
                                                                           heightDimension:[NSCollectionLayoutDimension fractionalWidthDimension:0.25]];
        
        NSCollectionLayoutGroup *group = [NSCollectionLayoutGroup horizontalGroupWithLayoutSize:groupSize subitems:@[item]];
        
        NSCollectionLayoutSection *section = [NSCollectionLayoutSection sectionWithGroup:group];
        
        //
        
        __kindof UIApplication *dashboard = UIApplication.sharedApplication;
        id displayManager = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(dashboard, sel_registerName("displayManager"));
        NSDictionary *displayToEnvironmentMap = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(displayManager, sel_registerName("displayToEnvironmentMap"));
        
        for (id display in displayToEnvironmentMap.allKeys) {
            BOOL isCarDisplay = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(display, sel_registerName("isCarDisplay"));
            
            if (isCarDisplay) {
                id environment = displayToEnvironmentMap[display];
                id configuration = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(environment, sel_registerName("environmentConfiguration"));
                
                id layoutEngine = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("DBDashboardLayoutEngine") alloc], sel_registerName("initWithEnvironmentConfiguration:"), configuration);
                UIEdgeInsets homeViewControllerInsets = reinterpret_cast<UIEdgeInsets (*)(id, SEL)>(objc_msgSend)(layoutEngine, sel_registerName("homeViewControllerInsets"));
                
                UITraitCollection *traitCollection = [layoutEnvironment traitCollection];
                
                if (traitCollection.layoutDirection == UITraitEnvironmentLayoutDirectionLeftToRight) {
                    section.contentInsets = NSDirectionalEdgeInsetsMake(homeViewControllerInsets.top, homeViewControllerInsets.left, homeViewControllerInsets.right, homeViewControllerInsets.bottom);
                } else {
                    section.contentInsets = NSDirectionalEdgeInsetsMake(homeViewControllerInsets.top, homeViewControllerInsets.right, homeViewControllerInsets.left, homeViewControllerInsets.bottom);
                }
                
                break;
            }
        }
        
        //
        
        
        return section;
    }
                                                                                                                       configuration:configuration];
    [configuration release];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];
    [collectionViewLayout release];
    
    collectionView.delegate = self;
    
    _collectionView = collectionView;
    return collectionView;
}

- (UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *)_dataSource {
    if (auto dataSource = _dataSource) return dataSource;
    
    UICollectionViewCellRegistration *cellRegistration = self.cellRegistration;
    
    UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *dataSource = [[UICollectionViewDiffableDataSource alloc] initWithCollectionView:self.collectionView cellProvider:^UICollectionViewCell * _Nullable(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, id  _Nonnull itemIdentifier) {
        return [collectionView dequeueConfiguredReusableCellWithRegistration:cellRegistration forIndexPath:indexPath item:itemIdentifier];
    }];
    
    _dataSource = dataSource;
    return dataSource;
}

- (UICollectionViewCellRegistration *)_cellRegistration {
    if (auto cellRegistration = _cellRegistration) return cellRegistration;
    
    UICollectionViewCellRegistration *cellRegistration = [UICollectionViewCellRegistration registrationWithCellClass:[UICollectionViewCell class] configurationHandler:^(UICollectionViewCell * _Nonnull cell, NSIndexPath * _Nonnull indexPath, CCPAppSwitcherItemModel * _Nonnull item) {
        CCPAppSwitcherIconContentConfiguration *contentConfiguration = [[CCPAppSwitcherIconContentConfiguration alloc] initWithItemModel:item];
        cell.contentConfiguration = contentConfiguration;
        [contentConfiguration release];
    }];
    
    _cellRegistration = [cellRegistration retain];
    return cellRegistration;
}

- (CCPAppSwitcherViewModel *)_viewModel {
    if (auto viewModel = _viewModel) return viewModel;
    
    CCPAppSwitcherViewModel *viewModel = [[CCPAppSwitcherViewModel alloc] initWithDataSource:self.dataSource];
    
    _viewModel = viewModel;
    return viewModel;
}

- (void)_didTriggerDoneBarButtonItem:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIContextMenuConfiguration *)collectionView:(UICollectionView *)collectionView contextMenuConfigurationForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths point:(CGPoint)point {
    CCPAppSwitcherViewModel *viewModel = self.viewModel;
    
    UIContextMenuConfiguration *configuration = [UIContextMenuConfiguration configurationWithIdentifier:nil
                                                                                        previewProvider:nil
                                                                                         actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        NSMutableArray<__kindof UIMenuElement *> *children = [suggestedActions mutableCopy];
        
        //
        
        UIAction *quitAction = [UIAction actionWithTitle:@"Quit" image:[UIImage systemImageNamed:@"xmark"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            [viewModel quitProcessForIndexPath:indexPaths[0]];
        }];
        
        quitAction.attributes = UIMenuOptionsDestructive;
        [children addObject:quitAction];
        
        //
        
        UIMenu *menu = [UIMenu menuWithChildren:children];
        [children release];
        
        return menu;
    }];
    
    return configuration;
}

@end
