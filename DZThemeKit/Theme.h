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

@property (nonatomic, copy) UIColor * _Nullable backgroundColor;

@property (nonatomic, copy) UIColor * _Nullable titleColor;

@property (nonatomic, copy) UIColor * _Nullable subtitleColor;

@property (nonatomic, copy) UIColor * _Nullable captionColor;

@property (nonatomic, copy) UIColor * _Nullable tableColor;

@property (nonatomic, copy) UIColor * _Nullable borderColor;

@property (nonatomic, copy) UIColor * _Nullable tintColor;

#pragma mark - Internals

@property (nonatomic, copy, readonly) NSString * _Nonnull name;

@property (nonatomic, assign, getter=isDark) BOOL dark NS_DEPRECATED_IOS(11.0, 12.3);

@property (nonatomic, assign) BOOL supportsDarkMode NS_AVAILABLE_IOS(13.0);

// used internally
@property (nonatomic, assign) BOOL updatingDarkBackingStore NS_AVAILABLE_IOS(13.0);


/**
 When subclassing this method, call super.
 */
- (void)updateAppearances;

- (void)setBOOL:(BOOL)value forKey:(NSString * _Nonnull)key;

- (BOOL)boolForKey:(NSString * _Nonnull)key;

- (void)setFloat:(CGFloat)value forKey:(NSString * _Nonnull)key;

- (CGFloat)floatForKey:(NSString * _Nonnull)key;

// to be implemented by subclasses
@property (nonatomic, strong, readonly) NSArray <NSString *> * _Nullable additionalKeyPaths NS_AVAILABLE_IOS(13.0);

- (void)updateWithDynamicColors:(NSArray <NSString *> * _Nonnull)colorKeys NS_AVAILABLE_IOS(13.0);

@end
