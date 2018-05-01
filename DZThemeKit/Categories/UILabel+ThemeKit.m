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

- (void)tk_updateTitleColor
{
    self.textColor = [MyThemeKit.theme titleColor];
}

- (void)tk_updateSubtitleColor
{
    self.textColor = [MyThemeKit.theme subtitleColor];
}

- (void)tk_updateCaptionColor
{
    self.textColor = [MyThemeKit.theme captionColor];
}

@end
