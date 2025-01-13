//
//  CCPAppSwitcherIconContentView.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherIconContentView.h"
#import <objc/message.h>
#import <objc/runtime.h>
#include <ranges>

/*
 (lldb) po [NSObject _fd__protocolDescriptionForProtocol:(Protocol *)NSProtocolFromString(@"SBIconViewDelegate")]
 <SBIconViewDelegate: 0x103bb6220> (SBIconViewActionDelegate, SBIconViewBehaviorDelegate, SBIconViewReuseDelegate, SBIconViewDragDelegate, SBIconViewShortcutsDelegate, SBIconViewConfigurationUIDelegate, NSObject) :
 in SBIconViewDelegate:
 Instance Methods:
 - (id) actionDelegateForIconView:(id)arg1;
 - (id) behaviorDelegateForIconView:(id)arg1;
 - (id) configurationUIDelegateForIconView:(id)arg1;
 - (id) draggingDelegateForIconView:(id)arg1;
 - (id) reuseDelegateForIconView:(id)arg1;
 - (id) shortcutsDelegateForIconView:(id)arg1;
 */

@interface CCPAppSwitcherIconContentView ()
@property (retain, nonatomic, readonly, getter=_snapshotImageView) UIImageView *snapshotImageView;
@property (retain, nonatomic, readonly, getter=_iconView) __kindof UIView *iconView;
@property (retain, nonatomic, readonly, getter=_statusLabel) UILabel *statusLabel;
@property (retain, nonatomic, getter=_timer, setter=_setTimer:) NSTimer *timer;
@end

@implementation CCPAppSwitcherIconContentView
@synthesize configuration = _configuration;
@synthesize snapshotImageView = _snapshotImageView;
@synthesize iconView = _iconView;
@synthesize statusLabel = _statusLabel;
@synthesize timer = _timer;

+ (void)load {
    if (Protocol *SBIconViewDelegate = NSProtocolFromString(@"SBIconViewDelegate")) {
        assert(class_addProtocol(self, SBIconViewDelegate));
    }
}

- (instancetype)initWithConfiguration:(CCPAppSwitcherIconContentConfiguration *)configuration {
    if (self = [super initWithFrame:CGRectNull]) {
        UIImageView *snapshotImageView = self.snapshotImageView;
        [self addSubview:snapshotImageView];
        reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(self, sel_registerName("_addBoundsMatchingConstraintsForView:"), snapshotImageView);
        
        __kindof UIView *iconView = self.iconView;
        [self addSubview:iconView];
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [iconView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [iconView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
        ]];
        
        UILabel *statusLabel = self.statusLabel;
        [self addSubview:statusLabel];
        statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
            [statusLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
            [statusLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
        ]];
        
        statusLabel.hidden = YES;
        
        self.configuration = configuration;
    }
    
    return self;
}

- (void)dealloc {
    [_configuration release];
    [_iconView release];
    [_snapshotImageView release];
    [_statusLabel release];
    [_timer invalidate];
    [_timer release];
    [super dealloc];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window == nil) {
        [self.timer invalidate];
        self.timer = nil;
    } else {
        assert(self.timer == nil);
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2. target:self selector:@selector(_didTriggerTimer:) userInfo:nil repeats:YES];
        [NSRunLoop.mainRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
        self.timer = timer;
    }
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:[CCPAppSwitcherIconContentConfiguration class]];
}

- (UIImageView *)_snapshotImageView {
    if (auto snapshotImageView = _snapshotImageView) return snapshotImageView;
    
    UIImageView *snapshotImageView = [UIImageView new];
    snapshotImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _snapshotImageView = snapshotImageView;
    return snapshotImageView;
}

- (__kindof UIView *)_iconView {
    if (auto iconView = _iconView) return iconView;
    
    __kindof UIView *iconView = [objc_lookUpClass("DBIconView") new];
    
    iconView.layer.shadowColor = UIColor.blackColor.CGColor;
    iconView.layer.shadowOpacity = 0.75;
    iconView.layer.shadowOffset = CGSizeZero;
    iconView.layer.shadowRadius = 10.;
    iconView.transform = CGAffineTransformScale(CGAffineTransformMakeTranslation(0., 35.), 0.75, 0.75);
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(iconView, sel_registerName("setDelegate:"), self);
    iconView.userInteractionEnabled = NO;
    
    _iconView = iconView;
    return iconView;
}

- (UILabel *)_statusLabel {
    if (auto statusLabel = _statusLabel) return statusLabel;
    
    UILabel *statusLabel = [UILabel new];
    statusLabel.textColor = UIColor.whiteColor;
    statusLabel.backgroundColor = UIColor.blackColor;
    
    _statusLabel = statusLabel;
    return statusLabel;
}

- (void)setConfiguration:(CCPAppSwitcherIconContentConfiguration *)configuration {
    if ([_configuration isEqual:configuration]) return;
    
    [_configuration release];
    
    CCPAppSwitcherIconContentConfiguration *copy = [configuration copy];
    
    _configuration = copy;
    
    id icon = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("DBLeafIcon") alloc], sel_registerName("initWithApplicationInfo:"), copy.itemModel.applicationInfo);
    reinterpret_cast<void (*)(id, SEL, id, BOOL)>(objc_msgSend)(self.iconView, sel_registerName("setIcon:animated:"), icon, NO);
    [icon release];
    
    switch (copy.itemModel.state) {
        case 0:
            self.statusLabel.text = @"Not Running";
            break;
        case 2:
            self.statusLabel.text = @"Background";
            break;
        case 8:
            self.statusLabel.text = @"Foreground";
            break;
        default:
            self.statusLabel.text = [NSString stringWithFormat:@"Status: %ld", copy.itemModel.state];
            break;
    }
    
    //
    
    [UIView animateWithDuration:0.2 animations:^{
        self.snapshotImageView.alpha = (copy.isSelected or copy.isHighlighted) ? 0.5 : 1.;
    }];
    
    //
    
    self.snapshotImageView.image = nil;
    [self _didTriggerTimer:nil];
}

- (void)_didTriggerTimer:(NSTimer *)sender {
    CCPAppSwitcherIconContentConfiguration *configuration = self.configuration;
    if (configuration == nil) return;
    
//    NSString *bundleIdentifier = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(configuration.itemModel.applicationInfo, sel_registerName("bundleIdentifier"));
    id snapshotMenifest = reinterpret_cast<id (*)(id, SEL, id)>(objc_msgSend)([objc_lookUpClass("XBApplicationSnapshotManifest") alloc], sel_registerName("initWithApplicationInfo:"), configuration.itemModel.applicationInfo);
    id manifestImpl = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(snapshotMenifest, sel_registerName("manifestImpl"));
    [snapshotMenifest release];
    
    NSDictionary<NSString *, id> *_snapshotGroupsByID;
    assert(object_getInstanceVariable(manifestImpl, "_snapshotGroupsByID", reinterpret_cast<void **>(&_snapshotGroupsByID)) != NULL);
    
    NSMutableArray *allSnapshots = [NSMutableArray new];
    
    for (NSString *sceneID in _snapshotGroupsByID.allKeys) {
        //            if (![sceneID hasPrefix:[NSString stringWithFormat:@"sceneID:%@", bundleIdentifier]]) continue;
        
        id group = _snapshotGroupsByID[sceneID];
        NSSet *snapshots = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(group, sel_registerName("snapshots"));
        [allSnapshots addObjectsFromArray:snapshots.allObjects];
    }
    
    [allSnapshots sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString * _Nullable launchInterfaceIdentifier_1 = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(obj1, sel_registerName("launchInterfaceIdentifier"));
        NSString * _Nullable launchInterfaceIdentifier_2 = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(obj2, sel_registerName("launchInterfaceIdentifier"));
        
        if ((launchInterfaceIdentifier_1 == nil) and (launchInterfaceIdentifier_2 != nil)) {
            return NSOrderedAscending;
        } else if ((launchInterfaceIdentifier_1 != nil) and (launchInterfaceIdentifier_2 == nil)) {
            return NSOrderedDescending;
        }
        
        NSDate *date_1 = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(obj1, sel_registerName("creationDate"));
        NSDate *date_2 = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(obj2, sel_registerName("creationDate"));
        
        return [date_2 compare:date_1];
    }];
    
    for (id snapshot in allSnapshots) {
        reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(snapshot, sel_registerName("beginImageAccess"));
        
        __kindof UIImage * _Nullable snapshotImage = nil;
        for (NSInteger interfaceOrientation : std::views::iota(0, 4)) {
            snapshotImage = reinterpret_cast<id (*)(id, SEL, NSInteger)>(objc_msgSend)(snapshot, sel_registerName("imageForInterfaceOrientation:"), interfaceOrientation);
            if (snapshotImage != nil) break;
        }
        
        reinterpret_cast<void (*)(id, SEL)>(objc_msgSend)(snapshot, sel_registerName("endImageAccess"));
        
        if (snapshotImage != nil) {
            self.snapshotImageView.image = snapshotImage;
            break;
        }
    }
    
    [allSnapshots release];
    
}

- (void)iconTapped:(id)icon {
    
}

@end
