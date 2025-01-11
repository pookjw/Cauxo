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

@interface CCPAppSwitcherViewController ()
@property (retain, nonatomic, readonly, getter=_doneBarButtonItem) UIBarButtonItem *doneBarButtonItem;
@end

@implementation CCPAppSwitcherViewController
@synthesize doneBarButtonItem = _doneBarButtonItem;

- (void)dealloc {
    [_doneBarButtonItem release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.doneBarButtonItem;
    
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

- (UIBarButtonItem *)_doneBarButtonItem {
    if (auto doneBarButtonItem = _doneBarButtonItem) return doneBarButtonItem;
    
    UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_didTriggerDoneBarButtonItem:)];
    
    _doneBarButtonItem = doneBarButtonItem;
    return doneBarButtonItem;
}

- (void)_didTriggerDoneBarButtonItem:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
