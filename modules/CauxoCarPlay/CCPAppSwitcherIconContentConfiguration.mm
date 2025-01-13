//
//  CCPAppSwitcherIconContentConfiguration.mm
//  CauxoCarPlay
//
//  Created by Jinwoo Kim on 1/13/25.
//

#import "CCPAppSwitcherIconContentConfiguration.h"
#import "CCPAppSwitcherIconContentView.h"

@interface CCPAppSwitcherIconContentConfiguration ()
@property (assign, nonatomic, getter=isSelected) BOOL selected;
@property (assign, nonatomic, getter=isHighlighted) BOOL highlighted;
@end

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
        copy->_selected = _selected;
        copy->_highlighted = _highlighted;
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
    (_itemModel.state == casted->_itemModel.state) and
    (_selected == casted->_selected) &&
    (_highlighted == casted->_highlighted);
}

- (NSUInteger)hash {
    return [_itemModel.applicationInfo hash] ^ _itemModel.state ^ _selected ^ _highlighted;
}

- (__kindof UIView<UIContentView> *)makeContentView {
    return [[[CCPAppSwitcherIconContentView alloc] initWithConfiguration:self] autorelease];
}

- (instancetype)updatedConfigurationForState:(id<UIConfigurationState>)state {
    if ([state isKindOfClass:[UICellConfigurationState class]]) {
        auto casted = static_cast<UICellConfigurationState *>(state);
        BOOL isSelected = casted.isSelected;
        BOOL isHighlighted = casted.isHighlighted;
        
        if ((self.isSelected != isSelected) or (self.isHighlighted != isHighlighted)) {
            CCPAppSwitcherIconContentConfiguration *copy = [self copy];
            copy.selected = isSelected;
            copy.highlighted = isHighlighted;
            return [copy autorelease];
        }
    }
    
    return self;
}

@end
