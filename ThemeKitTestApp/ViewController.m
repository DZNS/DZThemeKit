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
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupView:nil];
    
    MyThemeKit.autoUpdatingTheme = YES;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(setupView:) name:ThemeNeedsUpdateNotification object:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return MyThemeKit.isDark ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)setupView:(NSNotification *)note
{
    __weak typeof(self) weakSelf = self;
    
    NSTimeInterval duration = note ? 1000 : 0;
    
    [UIView animateWithDuration:duration animations:^{
    
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.view.backgroundColor = [MyThemeKit valueForKey:@"backgroundColor"];
            
            for (UILabel *label in @[strongSelf.titleLabel, strongSelf.textLabel, strongSelf.subtextLabel, strongSelf.borderLabel, strongSelf.tintLabel, strongSelf.customLabel]) {
                [label tk_updateSubtextColorForTheme];
                [label tk_updateBackgroundColor];
            }
            
            strongSelf.titleBlock.backgroundColor   = [MyThemeKit valueForKey:@"titleColor"];
            strongSelf.textBlock.backgroundColor    = [MyThemeKit valueForKey:@"textColor"];
            strongSelf.subtextBlock.backgroundColor = [MyThemeKit valueForKey:@"subtextColor"];
            strongSelf.borderBlock.backgroundColor  = [MyThemeKit valueForKey:@"borderColor"];
            strongSelf.tintBlock.backgroundColor    = [MyThemeKit valueForKey:@"tintColor"];
            strongSelf.customBlock.backgroundColor  = [MyThemeKit valueForKey:@"customColor"];
        });

    } completion:^(BOOL finished) {
    
        __strong typeof(weakSelf) strongSelf = weakSelf;
    
        [strongSelf setNeedsStatusBarAppearanceUpdate];
        
    }];
}

@end
