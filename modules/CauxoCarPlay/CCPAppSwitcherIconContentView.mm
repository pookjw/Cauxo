//
//  CCPAppSwitcherIconContentView.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherIconContentView.h"
#import <objc/message.h>
#import <objc/runtime.h>

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

@implementation CCPAppSwitcherIconContentConfiguration

+ (void)load {
    if (Protocol *SBIconViewDelegate = NSProtocolFromString(@"SBIconViewDelegate")) {
        assert(class_addProtocol(self, SBIconViewDelegate));
    }
}

- (instancetype)initWithItemModel:(CCPAppSwitcherItemModel *)itemModel {
    if (self = [super init]) {
        _itemModel = [itemModel copy];
    }
    
    return self;
}

- (void)dealloc {
    [_itemModel release];
    [super dealloc];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    CCPAppSwitcherIconContentConfiguration *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_itemModel = [_itemModel copyWithZone:zone];
    }
    
    return copy;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    
    if (![other isKindOfClass:[CCPAppSwitcherIconContentConfiguration class]]) {
        return NO;
    }
    
    auto casted = static_cast<CCPAppSwitcherIconContentConfiguration *>(other);
    
    return ([_itemModel.applicationInfo isEqual:casted->_itemModel.applicationInfo]) and
    (_itemModel.state == casted->_itemModel.state);
}

- (NSUInteger)hash {
    return [_itemModel.applicationInfo hash] ^ _itemModel.state;
}

- (__kindof UIView<UIContentView> *)makeContentView {
    return [[[CCPAppSwitcherIconContentView alloc] initWithConfiguration:self] autorelease];
}

- (instancetype)updatedConfigurationForState:(id<UIConfigurationState>)state {
    return self;
}

@end

@interface CCPAppSwitcherIconContentView ()
@property (retain, nonatomic, readonly, getter=_iconView) __kindof UIView *iconView;
@property (retain, nonatomic, readonly, getter=_statusLabel) UILabel *statusLabel;
@end

@implementation CCPAppSwitcherIconContentView
@synthesize configuration = _configuration;
@synthesize statusLabel = _statusLabel;
@synthesize iconView = _iconView;

- (instancetype)initWithConfiguration:(CCPAppSwitcherIconContentConfiguration *)configuration {
    if (self = [super initWithFrame:CGRectNull]) {
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
            [statusLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor]
        ]];
        
        self.configuration = configuration;
    }
    
    return self;
}

- (void)dealloc {
    [_configuration release];
    [_statusLabel release];
    [_iconView release];
    [super dealloc];
}

- (BOOL)supportsConfiguration:(id<UIContentConfiguration>)configuration {
    return [configuration isKindOfClass:[CCPAppSwitcherIconContentConfiguration class]];
}

- (__kindof UIView *)_iconView {
    if (auto iconView = _iconView) return iconView;
    
    __kindof UIView *iconView = [objc_lookUpClass("DBIconView") new];
    
    reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(iconView, sel_registerName("setDelegate:"), self);
    
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
}

- (void)iconTapped:(id)icon {
    __kindof UIViewController *_viewControllerForAncestor = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(self, sel_registerName("_viewControllerForAncestor"));
    [_viewControllerForAncestor dismissViewControllerAnimated:YES completion:^{
        /*
         -[DBDashboard handleEvent:]
         -[DBDashboard _handleOpenApplicationEvent:]
         
         ---
         
         -[DBEvent initWithType:context:]
         -> type = 4 - Open,  1 - Home (takeScreen)
         -> context = DBApplicationLaunchInfo
            -> -[DBApplicationLaunchInfo initWithApplication:activationSettings:]
                -> (x2) DBApplicationInfo
                -> (x3 - Open App) {DBActivationSettingLaunchSource = 3}
                -> (x3 - Home) @(0)
         
         -[DBDashboard handleEvent:]
         */
        
        CCPAppSwitcherIconContentConfiguration *contentConfiguration = self.configuration;
        if (contentConfiguration == nil) return;
        
        id context = reinterpret_cast<id (*)(id, SEL, id, id)>(objc_msgSend)([objc_lookUpClass("DBApplicationLaunchInfo") alloc], sel_registerName("initWithApplication:activationSettings:"), contentConfiguration.itemModel.applicationInfo, @{@"DBActivationSettingLaunchSource": @(3)});
        
        id event = reinterpret_cast<id (*)(id, SEL, NSUInteger, id)>(objc_msgSend)([objc_lookUpClass("DBEvent") alloc], sel_registerName("initWithType:context:"), 4, context);
        [context release];
        
        __kindof UIApplication *dashboard = UIApplication.sharedApplication;
        id displayManager = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(dashboard, sel_registerName("displayManager"));
        NSDictionary *displayToEnvironmentMap = reinterpret_cast<id (*)(id, SEL)>(objc_msgSend)(displayManager, sel_registerName("displayToEnvironmentMap"));
        
        for (id display in displayToEnvironmentMap.allKeys) {
            BOOL isCarDisplay = reinterpret_cast<BOOL (*)(id, SEL)>(objc_msgSend)(display, sel_registerName("isCarDisplay"));
            
            if (isCarDisplay) {
                id environment = displayToEnvironmentMap[display];
                
                reinterpret_cast<void (*)(id, SEL, id)>(objc_msgSend)(environment, sel_registerName("handleEvent:"), event);
                break;
            }
        }
        
        [event release];
    }];
}

@end
