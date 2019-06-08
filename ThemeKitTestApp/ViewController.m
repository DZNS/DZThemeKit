//
//  ViewController.m
//  ThemeKitTestApp
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "ViewController.h"
#import <DZThemeKit/DZThemeKit.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIView *titleBlock;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *textBlock;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@property (weak, nonatomic) IBOutlet UIView *subtextBlock;
@property (weak, nonatomic) IBOutlet UILabel *subtextLabel;

@property (weak, nonatomic) IBOutlet UIView *borderBlock;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;

@property (weak, nonatomic) IBOutlet UIView *tintBlock;
@property (weak, nonatomic) IBOutlet UILabel *tintLabel;

@property (weak, nonatomic) IBOutlet UIView *customBlock;
@property (weak, nonatomic) IBOutlet UILabel *customLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [ThemeKit loadThemeKit];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupView:nil];
    
    if (@available(iOS 13, *)) {}
    else {
        MyThemeKit.autoUpdatingTheme = YES;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setupView:) name:ThemeNeedsUpdateNotification object:nil];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (@available (iOS 13, *)) {
        return self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? UIStatusBarStyleDarkContent : UIStatusBarStyleDefault;
    }
    
    return MyThemeKit.theme.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setupView:(NSNotification *)note
{
    __weak typeof(self) weakSelf = self;
    
    MyThemeKit.theme = MyThemeKit.isDark ? [MyThemeKit themeNamed:@"colours-dark"] : [MyThemeKit themeNamed:@"colours"];
    
    NSTimeInterval duration = note ? 1000 : 0;
    
    [UIView animateWithDuration:duration animations:^{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.view.backgroundColor = MyThemeKit.theme.backgroundColor;
            
            for (UILabel *label in @[strongSelf.titleLabel, strongSelf.textLabel, strongSelf.subtextLabel, strongSelf.borderLabel, strongSelf.tintLabel, strongSelf.customLabel]) {
                [label tk_updateSubtitleColor];
                [label tk_updateBackgroundColor];
            }
            
            strongSelf.titleBlock.backgroundColor   = MyThemeKit.theme.titleColor;
            strongSelf.textBlock.backgroundColor    = MyThemeKit.theme.subtitleColor;
            strongSelf.subtextBlock.backgroundColor = MyThemeKit.theme.captionColor;
            strongSelf.borderBlock.backgroundColor  = MyThemeKit.theme.borderColor;
            strongSelf.tintBlock.backgroundColor    = MyThemeKit.theme.tintColor;
            strongSelf.customBlock.backgroundColor  = [MyThemeKit.theme valueForKey:@"customColor"];
        });

    } completion:^(BOOL finished) {
    
        __strong typeof(weakSelf) strongSelf = weakSelf;
    
        [strongSelf setNeedsStatusBarAppearanceUpdate];
        
    }];
}

@end
