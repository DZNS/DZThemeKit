//
//  ThemeKit.h
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ThemeKit;

extern ThemeKit * _Nonnull MyThemeKit;

@interface ThemeKit : NSObject

@property (nonatomic, copy) UIColor * _Nonnull backgroundColor;
@property (nonatomic, copy) UIColor * _Nonnull textColor;
@property (nonatomic, copy) UIColor * _Nonnull subtextColor;
@property (nonatomic, copy) UIColor * _Nonnull titleColor;
@property (nonatomic, copy) UIColor * _Nonnull borderColor;
@property (nonatomic, copy) UIColor * _Nonnull tintColor;

- (void)loadColorsFromFile:(NSURL * _Nonnull)path;

@end
