//
//  Theme.h
//  DZThemeKit
//
//  Created by Nikhil Nigade on 01/05/18.
//  Copyright © 2018 Dezine Zync Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Theme : NSObject

@property (nonatomic, copy) UIColor *backgroundColor;

@property (nonatomic, copy) UIColor *titleColor;

@property (nonatomic, copy) UIColor *subtitleColor;

@property (nonatomic, copy) UIColor *captionColor;

@property (nonatomic, copy) UIColor *tableColor;

@property (nonatomic, copy) UIColor *borderColor;

@property (nonatomic, copy) UIColor *tintColor;

#pragma mark - Internals

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, assign, getter=isDark) BOOL dark;


/**
 When subclassing this method, call super.
 */
- (void)updateAppearances;

- (void)setBOOL:(BOOL)value forKey:(NSString * _Nonnull)key;

- (BOOL)boolForKey:(NSString * _Nonnull)key;

- (void)setFloat:(CGFloat)value forKey:(NSString * _Nonnull)key;

- (CGFloat)floatForKey:(NSString * _Nonnull)key;

@end
