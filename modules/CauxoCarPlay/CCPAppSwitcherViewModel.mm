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
@property (retain, nonatomic, readonly, getter=_queue) dispatch_queue_t queue;
@property (retain, nonatomic, readonly, getter=_dataSource) UICollectionViewDiffableDataSource<NSNull *, id> *dataSource;
@end

@implementation CCPAppSwitcherViewModel

- (instancetype)initWithDataSource:(UICollectionViewDiffableDataSource<NSNull *,id> *)dataSource {
    if (self = [super init]) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_UTILITY, QOS_MIN_RELATIVE_PRIORITY);
        dispatch_queue_t queue = dispatch_queue_create("CauxoCarPlay App Switcher Queue", attr);
        
        _queue = queue;
        
        _dataSource = [dataSource retain];
    }
    
    return self;
}

- (void)dealloc {
    if (_queue) {
        dispatch_release(_queue);
    }
    
    [_dataSource release];
    [super dealloc];
}

@end
