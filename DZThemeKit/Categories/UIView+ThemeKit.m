//
//  UIView+ThemeKit.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "UIView+ThemeKit.h"
#import "ThemeKit.h"

@implementation UIView (ThemeKit)

- (void)tk_updateBackgroundColor
{
    self.backgroundColor = [MyThemeKit.theme backgroundColor];
}

@end
