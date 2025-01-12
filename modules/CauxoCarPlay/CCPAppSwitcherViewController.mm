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

@interface CCPAppSwitcherViewController ()
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
    self.navigationItem.title = @"App Switcher";
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
    
//    UICollectionLayoutListConfiguration *listConfiguration = [[UICollectionLayoutListConfiguration alloc] initWithAppearance:UICollectionLayoutListAppearanceInsetGrouped];
//    
//    UICollectionViewCompositionalLayout *collectionViewLayout = [UICollectionViewCompositionalLayout layoutWithListConfiguration:listConfiguration];
//    [listConfiguration release];
    
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
        
        return section;
    }
                                                                                                                       configuration:configuration];
    [configuration release];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectNull collectionViewLayout:collectionViewLayout];
    [collectionViewLayout release];
    
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

@end
