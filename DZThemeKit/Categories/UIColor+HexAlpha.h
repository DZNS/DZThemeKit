//
//  UIColor+HexAlpha.h
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexAlpha)

+ (UIColor *)colorFromHex:(NSString *)hex;

+ (UIColor *)colorFromHex:(NSString *)hex p3:(BOOL)p3;

+ (UIColor *)colorFromHex:(NSString *)hex p3:(BOOL)p3 fromRGB:(BOOL)fromRGB;

@end
