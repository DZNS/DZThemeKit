//
//  ThemeKit.h
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <DZThemeKit/Theme.h>

@class ThemeKit;

/**
 You can observe this notification in your views or it's controllers to auto update them when the theme is changed or updated.
 */
extern NSNotificationName _Nonnull const ThemeNeedsUpdateNotification;

extern NSNotificationName _Nonnull const ThemeWillUpdate;
extern NSNotificationName _Nonnull const ThemeDidUpdate;

/**
 This is the shared instance of ThemeKit for simpler access.
 */
extern ThemeKit * _Nonnull MyThemeKit;

@interface ThemeKit : NSObject

+ (Class)themeClass;

/**
 Initialize DZThemeKit. Makes MyThemeKit available.
 */
+ (void)loadThemeKit;

/**
 The currently active theme.
 */
@property (nonatomic, weak) Theme *theme;

/**
 All the themes that have been currently loaded.
 */
@property (nonatomic, strong, readonly) NSArray <Theme *> *themes;

- (Theme *)themeNamed:(NSString *)name;

/**
 Load your theme colours' configuration for a JSON file at the given path.
 If a theme already exists and is loaded, it'll be overwritten.

 @param path An NSURL object for the file. It's recommended that this is obtained by using the [NSBungle bundleForClass:] API.
 */
- (Theme *)loadColorsFromFile:(NSURL * _Nonnull)path;

/**
 Setting this to YES fires the ThemeNeedsUpdateNotification whenever the device's display brightness dips below a certain threshold.
 This only works when you have a dark theme associated with the theme you loaded earlier using -[MyThemeKit loadColorsFromFile:].
 If a dark theme isn't available, setting this to YES has no effect.
 */
@property (nonatomic) BOOL autoUpdatingTheme;

/**
 When autoupdating, you can reference this value for additional setups like updating the status bar colour, etc. Setting a value will override the existing value. If you need a fixed value, ensure you have turned off autoUpdatingTheme.
 */
@property (nonatomic, getter=isDark) BOOL useDark;

@end
