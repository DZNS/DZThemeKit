//
//  UILabel+ThemeKit.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "UILabel+ThemeKit.h"
#import "ThemeKit.h"

@implementation UILabel (ThemeKit)

- (void)tk_updateTitleColorForTheme
{
    self.textColor = [MyThemeKit valueForKey:@"titleColor"];
}

- (void)tk_updateTextColorForTheme
{
    self.textColor = [MyThemeKit valueForKey:@"textColor"];
}

- (void)tk_updateSubtextColorForTheme
{
    self.textColor = [MyThemeKit valueForKey:@"subtextColor"];
}

@end
