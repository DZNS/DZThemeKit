//
//  ThemeKit.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import "ThemeKit.h"
#import "UIColor+HexAlpha.h"

ThemeKit *MyThemeKit;
NSNotificationName const ThemeNeedsUpdateNotification = @"com.dezinezync.themekit.needsUpdateNotification";
NSNotificationName const ThemeWillUpdate = @"com.dezinezync.themekit.willUpdateNotification";
NSNotificationName const ThemeDidUpdate = @"com.dezinezync.themekit.didUpdateNotification";

@interface ThemeKit () {
    BOOL _brightnessNoteRegistered;
}

@property (nonatomic, strong, readwrite) NSArray <Theme *> *themes;

@end

@implementation ThemeKit

+ (Class)themeClass {
    return Theme.class;
}

+ (void)loadThemeKit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MyThemeKit = [[ThemeKit alloc] init];
    });
}

#pragma mark -

- (instancetype)init
{
    if (self = [super init]) {
        
        self.themes = @[];
#ifdef DEBUG
        NSBundle *classBundle = [NSBundle bundleForClass:self.class];
        NSString *path = [classBundle pathForResource:@"colours" ofType:@"json"];

        NSURL *url = [NSURL URLWithString:path];
        [self loadColorsFromFile:url];
#endif
    }
    
    return self;
}

#pragma mark - Instance Methods

- (Theme *)loadColorsFromFile:(NSURL *)path {
    return [self loadColorsFromFile:path forDark:NO];
}

- (Theme *)loadColorsFromFile:(NSURL *)path forDark:(BOOL)forDark {
    
    if(!path)
        return nil;
    
    NSData *contents =  [[NSData alloc] initWithContentsOfFile:path.path];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:contents options:kNilOptions error:&error];
    
    if (error)
        @throw error;
    
    NSString *name = [[[path lastPathComponent] componentsSeparatedByString:@"."] firstObject];
    
    Class ThemeClass = [[self class] themeClass];
    
    Theme *theme = [[ThemeClass alloc] init];
    [theme setValue:name forKeyPath:@"name"];
    theme.dark = forDark;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:NSString.class] && [key containsString:@"Color"]) {
            UIColor *color = [UIColor colorFromHex:obj];
            
            [theme setValue:color forKey:key];
        }
        else if ([obj isKindOfClass:NSDictionary.class] && [key containsString:@"Color"]) {
            NSDictionary *subdict = obj;
            
            if (![subdict valueForKey:@"rgb"])
                return;
            
            NSMutableDictionary *setDict = @{}.mutableCopy;
            
            // base color in sRGB
            UIColor *color = [UIColor colorFromHex:[subdict valueForKey:@"rgb"]];
            
            [setDict setObject:color forKey:@"rgb"];
            
            // check for P3 preference
            id p3val = [subdict valueForKey:@"p3"];
            if (p3val) {
                if ([p3val isKindOfClass:NSString.class]) {
                    // we have a direct colour from the user. Use it directly.
                    UIColor *p3color = [UIColor colorFromHex:p3val p3:YES fromRGB:NO];
                    [setDict setObject:p3color forKey:@"p3"];
                    
                }
                else if ([p3val isKindOfClass:NSNumber.class] && [p3val boolValue]) {
                    // convert rgb color to p3
                    UIColor *p3color = [UIColor colorFromHex:[subdict valueForKey:@"rgb"] p3:YES fromRGB:YES];
                    [setDict setObject:p3color forKey:@"p3"];
                }
            }
            
            [theme setValue:setDict.copy forKey:key];
        }
        else {
           [theme setValue:obj forKey:key];
        }
        
    }];
    
    if (@available(iOS 13, *)) {
        
        if (forDark == NO) {
            self.themes = [self.themes arrayByAddingObject:theme];
            
            if (!self.theme) {
                self.theme = [self.themes lastObject];
            }
        }
        
    }
    else {
        self.themes = [self.themes arrayByAddingObject:theme];
        
        if (!self.theme) {
            self.theme = [self.themes lastObject];
        }
    }
    
    // if there's a dark theme with the same name, load it as well.
    // also, dark themes cannot have darker themes. Well, let's hope not.
    if (![path.absoluteString containsString:@"dark"]) {
        
        NSString *filename = [[path lastPathComponent] stringByReplacingOccurrencesOfString:@".json" withString:@"-dark"];
        
        NSURL *pathStr = [[NSBundle bundleForClass:self.class] URLForResource:filename withExtension:@"json"];
        
        if (pathStr != nil) {
         
            // we don't want this to throw an error since the main objective has been achieved.
            @try {
                Theme *dark = [self loadColorsFromFile:pathStr forDark:YES];
                
                if (@available(iOS 13, *)) {
                    theme.supportsDarkMode = YES;
                    
                    NSMutableDictionary *lightProperties = [theme valueForKeyPath:@"backingStore"];
                    
                   NSMutableDictionary *properties = [dark valueForKeyPath:@"backingStore"];
                    
                    // add keypaths to the properties as well
                    NSArray <NSString *> *keypaths = @[@"backgroundColor", @"titleColor", @"subtitleColor", @"captionColor", @"tableColor", @"borderColor", @"tintColor"];
                    
                    NSArray <NSString *> *additionalKeyPaths = [theme additionalKeyPaths];
                    
                    if (additionalKeyPaths != nil && additionalKeyPaths.count > 0) {
                        keypaths = [keypaths arrayByAddingObjectsFromArray:additionalKeyPaths];
                    }
                    
                    for (NSString *keypath in keypaths) {
                        
                        // light theme
                        id lightVal = [theme valueForKeyPath:keypath];
                        
                        id val = [dark valueForKeyPath:keypath];
                        
                        if (lightVal) {
                            [lightProperties setObject:lightVal forKey:keypath];
                        }
                        
                        if (val) {
                            [properties setObject:val forKey:keypath];
                        }
                    }
                    
                    [theme setValue:lightProperties forKeyPath:@"lightBackingStore"];
                    
                    // being updating the dark backing store
                    theme.updatingDarkBackingStore = YES;
                    
                    [properties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                       
                        [theme setValue:obj forKey:key];
                        
                    }];
                    
                    // resolve all colour properties to dynamic providers
                    NSArray <NSString *> *colorKeys = [properties.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF ENDSWITH 'Color'"]];
                    
                    // end updating the dark backing store
                    theme.updatingDarkBackingStore = NO;
                    
                    // update the primary backing store with dynamic colours
                    [theme updateWithDynamicColors:colorKeys];
                }
                
            } @catch (NSException *exc) {}
        }
        
    }
    
    return theme;
    
}

- (Theme *)themeNamed:(NSString *)name {
    
    if (!name || ![name length])
    return nil;
    
    Theme *theme = nil;
    
    for (Theme *obj in self.themes) {
        if ([obj.name isEqualToString:name]) {
            theme = obj;
            break;
        }
    }
    
    return theme;
    
}

#pragma mark - Setters

- (void)setAutoUpdatingTheme:(BOOL)autoUpdatingTheme {
    
    _autoUpdatingTheme = autoUpdatingTheme;
    
    if (@available(iOS 13, *)) {
        return;
    }
    
    if (_autoUpdatingTheme) {
        
        // let's make sure we have a dark theme
        NSMutableArray *darkThemes = [NSMutableArray arrayWithCapacity:self.themes.count];
        
        for (Theme *theme in self.themes) {
            if (theme.isDark) {
                [darkThemes addObject:theme];
            }
        }
        
        if (darkThemes.count) {
            [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeBrightness:) name:UIScreenBrightnessDidChangeNotification object:nil];
            _brightnessNoteRegistered = YES;
            
            __weak typeof(self) weakSelf = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                [strongSelf didChangeBrightness:nil];
            });
        }
    }
    else if (_brightnessNoteRegistered) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIScreenBrightnessDidChangeNotification object:nil];
        _brightnessNoteRegistered = NO;
    }
}

- (void)setTheme:(Theme *)theme {
    
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center postNotificationName:ThemeWillUpdate object:MyThemeKit];
    
    _theme = theme;
    
    if (_theme) {
        [_theme updateAppearances];
        
        if (self.autoReloadWindow) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                
                if ([window isKindOfClass:NSClassFromString(@"UITextEffectsWindow")] == YES) {
                    // do not touch this window's subviews.
                    // really really bad things happen.
                    // It isn't a window we own either. So let's not touch it.
                    continue;
                }
                
                for (UIView *view in window.subviews) {
                    [view removeFromSuperview];
                    [window addSubview:view];
                }
            }
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] setNeedsStatusBarAppearanceUpdate];
    }
    
    [center postNotificationName:ThemeDidUpdate object:MyThemeKit];
    
}

#pragma mark - Notifications

- (void)didChangeBrightness:(NSNotification * _Nullable)note {
    
    BOOL newVal = UIScreen.mainScreen.brightness <= 0.4f;
#if TARGET_OS_SIMULATOR
    newVal = NO;
#endif
    BOOL fireNotification = newVal != _useDark;
    
    if (fireNotification) {
        _useDark = newVal;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:ThemeNeedsUpdateNotification object:nil];
        });
    }
}

@end
