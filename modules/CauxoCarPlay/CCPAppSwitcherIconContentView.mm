//
//  CCPAppSwitcherIconContentView.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/12/25.
//

#import "CCPAppSwitcherIconContentView.h"
#import <objc/message.h>
#import <objc/runtime.h>

@implementation CCPAppSwitcherIconContentConfiguration

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

@end
