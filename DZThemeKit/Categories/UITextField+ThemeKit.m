//
//  UITextField+ThemeKit.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "UITextField+ThemeKit.h"
#import "ThemeKit.h"

@implementation UITextField (ThemeKit)

- (void)tk_setTextColor
{
    self.textColor = [MyThemeKit.theme subtitleColor];
}

- (void)tk_setPlaceholderColor
{
    self.textColor = [MyThemeKit.theme valueForKey:@"placeholderColor"] ?: [MyThemeKit.theme captionColor];
}

@end

@implementation UITextView (ThemeKit)

- (void)tk_setTextColor
{
    self.textColor = [MyThemeKit.theme subtitleColor];
}

@end
