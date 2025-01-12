//
//  CCPAppSwitcherViewModel.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherViewModel.h"
#import <objc/message.h>
#import <objc/runtime.h>

/*
 LSApplicationWorkspace
 po [[LSApplicationWorkspace defaultWorkspace] allApplications]
 //    id monitor = [objc_lookUpClass("BKSApplicationStateMonitor") new];
 //
 //    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(monitor, sel_registerName("setHandler:"), ^(NSDictionary<NSString *, id> *info) {
 //        NSLog(@"%@", info);
 //    });
 */

@interface CCPAppSwitcherViewModel ()
@property (retain, nonatomic, readonly, getter=_dataSource) UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *dataSource;
@property (class, nonatomic, readonly, getter=_allDashboardApplications) NSArray *allDashboardApplications;
@property (retain, nonatomic, readonly, getter=_stateMonitor) id stateMonitor;
@property (nonatomic, readonly, getter=_calloutQueue) dispatch_queue_t calloutQueue;
@end

@implementation CCPAppSwitcherViewModel

- (instancetype)initWithDataSource:(UICollectionViewDiffableDataSource<NSNull *,CCPAppSwitcherItemModel *> *)dataSource {
    if (self = [super init]) {
        _dataSource = [dataSource retain];
        
        id stateMonitor = [objc_lookUpClass("BKSApplicationStateMonitor") new];
        _stateMonitor = stateMonitor;
        
        //
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didAddIconNotification:) name:@"SBIconModelDidAddIconNotification" object:nil];
        [self _updateInterestedBundleIDs];
        
        //
        
        reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(stateMonitor, sel_registerName("setHandler:"), ^(NSDictionary<NSString *, id> *info) {
            [CCPAppSwitcherViewModel _updateDataSource:dataSource stateMonitor:stateMonitor];
        });
        
        dispatch_async(self.calloutQueue, ^{
            [CCPAppSwitcherViewModel _updateDataSource:dataSource stateMonitor:stateMonitor];
        });
    }
    
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_dataSource release];
    [_stateMonitor release];
    [super dealloc];
}

- (void)_updateInterestedBundleIDs {
    NSArray *allDashboardApplications = CCPAppSwitcherViewModel.allDashboardApplications;
    NSMutableArray<NSString *> *bundleIdentifiers = [[NSMutableArray alloc] initWithCapacity:allDashboardApplications.count];
    for (id applicationInfo in allDashboardApplications) {
        NSString *bundleIdentifier = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(applicationInfo, sel_registerName("bundleIdentifier"));
        [bundleIdentifiers addObject:bundleIdentifier];
    }
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(self.stateMonitor, sel_registerName("updateInterestedBundleIDs:"), bundleIdentifiers);
    [bundleIdentifiers release];
}

- (void)_didAddIconNotification:(NSNotification *)notification {
    [self _updateInterestedBundleIDs];
    
    UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *dataSource = self.dataSource;
    id stateMonitor = self.stateMonitor;
    
    dispatch_async(self.calloutQueue, ^{
        [CCPAppSwitcherViewModel _updateDataSource:dataSource stateMonitor:stateMonitor];
    });
}

- (dispatch_queue_t)_calloutQueue {
    id stateMonitor = self.stateMonitor;
    
    id _monitor;
    assert(object_getInstanceVariable(stateMonitor, "_monitor", reinterpret_cast<void **>(&_monitor)) != NULL);
    dispatch_queue_t calloutQueue = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(_monitor, sel_registerName("calloutQueue"));
    
    return calloutQueue;
}

+ (void)_updateDataSource:(UICollectionViewDiffableDataSource<NSNull *, CCPAppSwitcherItemModel *> *)dataSource stateMonitor:(id)stateMonitor {
    NSArray *allDashboardApplications = CCPAppSwitcherViewModel.allDashboardApplications;
    NSDiffableDataSourceSnapshot<NSNull *, CCPAppSwitcherItemModel *> *oldSnapshot = dataSource.snapshot;
    
    NSDiffableDataSourceSnapshot<NSNull *, CCPAppSwitcherItemModel *> *snapshot = [NSDiffableDataSourceSnapshot new];
    [snapshot appendSectionsWithIdentifiers:@[[NSNull null]]];
    
    for (id applicationInfo in allDashboardApplications) {
        NSString *bundleIdentifier = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(applicationInfo, sel_registerName("bundleIdentifier"));
        NSUInteger state = reinterpret_cast<NSUInteger (*)(id, SEL, id)>(objc_msgSend)(stateMonitor, sel_registerName("applicationStateForApplication:"), bundleIdentifier);
        
        if ((state != 2) and (state != 8)) continue;
        
        CCPAppSwitcherItemModel *itemModel = [[CCPAppSwitcherItemModel alloc] initWithApplicationInfo:applicationInfo state:state];
        
        [snapshot appendItemsWithIdentifiers:@[itemModel] intoSectionWithIdentifier:[NSNull null]];
        
        if ([oldSnapshot.itemIdentifiers containsObject:itemModel]) {
            [snapshot reconfigureItemsWithIdentifiers:@[itemModel]];
        }
        
        [itemModel release];
    }
    
//    [dataSource applySnapshot:snapshot animatingDifferences:YES completion:nil];
    [dataSource applySnapshotUsingReloadData:snapshot completion:nil];
    [snapshot release];
}

+ (NSArray *)_allDashboardApplications {
    // -[DBDashboardHomeViewController allApplicationIcons]
    id configuration = [objc_lookUpClass("FBSApplicationLibraryConfiguration") new];
    
    reinterpret_cast<void (*)(id, SEL, Class)>(objc_msgSend)(configuration, sel_registerName("setApplicationInfoClass:"), objc_lookUpClass("DBApplicationInfo"));
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(configuration, sel_registerName("setInstalledApplicationFilter:"), ^BOOL (id proxy) {
        // __35+[DashBoard _newApplicationLibrary]_block_invoke
        NSSet<NSString *> *requiredEntitlementKeys = reinterpret_cast<id (*)(Class, SEL)>(objc_msgSend)(objc_lookUpClass("CRCarPlayAppDeclaration"), sel_registerName("requiredEntitlementKeys"));
        
        BOOL found = NO;
        
        for (NSString *key in requiredEntitlementKeys) {
            if ([key isEqualToString:@"com.apple.developer.carplay-protocols"]) {
                NSArray *value = reinterpret_cast<id (*)(id, SEL, id, Class)>(objc_msgSend)(proxy, sel_registerName("entitlementValueForKey:ofClass:"), key, [NSArray class]);
                if (value != nil) {
                    found = YES;
                    break;
                }
            } else {
                NSNumber *value = reinterpret_cast<id (*)(id, SEL, id, Class)>(objc_msgSend)(proxy, sel_registerName("entitlementValueForKey:ofClass:"), key, [NSNumber class]);
                if ((value != nil) and value.boolValue) {
                    found = YES;
                    break;
                }
            }
        }
        
        if (!found) return NO;
        
        NSString *bundleIdentifier = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(proxy, sel_registerName("bundleIdentifier"));
        
        id denylist = [objc_lookUpClass("CRCarPlayAppDenylist") new];
        BOOL isDeniedApp = reinterpret_cast<BOOL (*)(id, SEL, id)>(objc_msgSend)(denylist, sel_registerName("containsBundleIdentifier:"), bundleIdentifier);
        [denylist release];
        
        return !isDeniedApp;
    });
    
    id library = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("FBSApplicationLibrary") alloc], sel_registerName("initWithConfiguration:"), configuration);
    [configuration release];
    
    NSArray *allInstalledApplications = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(library, sel_registerName("allInstalledApplications"));
    [library release];
    
    // __52-[DBDashboardHomeViewController allApplicationIcons]_block_invoke
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nullable applicationInfo, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSArray *tags = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(applicationInfo, sel_registerName("tags"));
        if ([tags containsObject:@"hidden"]) return NO;
        
        __kindof UIApplication *dashboard = UIApplication.sharedApplication;
        id displayManager = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(dashboard, sel_registerName("displayManager"));
        NSDictionary *displayToEnvironmentMap = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(displayManager, sel_registerName("displayToEnvironmentMap"));
        
        for (id display in displayToEnvironmentMap.allKeys) {
            BOOL isCarDisplay = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(display, sel_registerName("isCarDisplay"));
            
            if (isCarDisplay) {
                id environment = displayToEnvironmentMap[display];
                id configuration = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(environment, sel_registerName("environmentConfiguration"));
                id policy = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)(configuration, sel_registerName("policyForApplicationInfo:"), applicationInfo);
                BOOL isCarPlaySupported = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(policy, sel_registerName("isCarPlaySupported"));
                
                return isCarPlaySupported;
            }
        }
        
        return NO;
    }];
    
    NSArray *finalApplications = [allInstalledApplications filteredArrayUsingPredicate:predicate];
    return finalApplications;
}

@end
