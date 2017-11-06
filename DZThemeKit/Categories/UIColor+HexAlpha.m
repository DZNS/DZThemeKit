//
//  UIColor+HexAlpha.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "UIColor+HexAlpha.h"

@implementation UIColor (HexAlpha)

+ (UIColor *)colorFromHex:(NSString *)hex
{
    return [UIColor colorFromHex:hex p3:NO];
}

+ (UIColor *)colorFromHex:(NSString *)hex p3:(BOOL)p3
{
    return [UIColor colorFromHex:hex p3:p3 fromRGB:YES];
}

+ (UIColor *)colorFromHex:(NSString *)hexString p3:(BOOL)p3 fromRGB:(BOOL)fromRGB
{
    if (!hexString)
        return nil;
    
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSInteger halfCount = 4;
    NSInteger fullCount = 8;
    
    CGFloat alpha = 1.f;
    NSInteger length = 0;
    if (hexString.length > halfCount && hexString.length < 6) {
        NSString *str = [hexString substringFromIndex:halfCount-1];
        length = str.length;
        // ensure we're not working with the colour itself
        alpha = (str.floatValue / (length > 1 ? 100.f : 10.f)) ?: 1.f;
    }
    else if (hexString.length == fullCount) {
        alpha = [hexString substringFromIndex:fullCount-2].floatValue / 100.f;
        length = 2;
    }
    
    hexString = [hexString substringToIndex:hexString.length-length];
    
    // half-code
    if (hexString.length == 4 || hexString.length == 3) {
        __block NSArray *components = @[];
        
        [hexString enumerateSubstringsInRange:NSMakeRange(0, hexString.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            components = [components arrayByAddingObject:substring];
        }];
        
        NSMutableArray *newComponents = @[].mutableCopy;
        // skip the # char since we don't really need it
        if (hexString.length == 4)
            components = [components subarrayWithRange:NSMakeRange(1, 3)];
        
        for (NSString *comp in components) {
            [newComponents addObjectsFromArray:@[comp, comp]];
        }
        
        hexString = [newComponents componentsJoinedByString:@""];
        
    }
        
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    if (p3) {
        if (fromRGB) {
            CGFloat red = ((rgbValue & 0xFF0000) >> 16)/255.0;
            CGFloat green = ((rgbValue & 0xFF00) >> 8)/255.0;
            CGFloat blue = (rgbValue & 0xFF)/255.0;
            
            red = [UIColor transferedToP3ColorSpace:red];
            green = [UIColor transferedToP3ColorSpace:green];
            blue = [UIColor transferedToP3ColorSpace:blue];
            
            return [UIColor colorWithDisplayP3Red:red green:green blue:blue alpha:alpha];
        }
        else
            return [UIColor colorWithDisplayP3Red:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
    }
    else
        return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

// convert using transfer function
// https://drafts.csswg.org/css-color/#predefined
+ (CGFloat)transferedToP3ColorSpace:(CGFloat)C {
    CGFloat Cl = C;
    if (C <= 0.04045)
        Cl = C / 12.92;
    else
        Cl = pow((C + 0.055) / 1.055, 2.4);
    
    return Cl;
}

@end
