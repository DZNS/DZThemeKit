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
NSString *const ThemeNeedsUpdateNotification = @"com.dezinezync.themekit.needsUpdateNotification";

@interface ThemeKit () {
    BOOL _brightnessNoteRegistered;
}

@property (nonatomic, strong) NSMutableDictionary *additionals;
@property (nonatomic, strong) NSMutableDictionary *dark;

@end

@implementation ThemeKit

+ (void)load
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
        _additionals = @{}.mutableCopy;
        
        NSBundle *classBundle = [NSBundle bundleForClass:self.class];
        NSString *path = [classBundle pathForResource:@"colours" ofType:@"json"];
        
        NSURL *url = [NSURL URLWithString:path];
        [self loadColorsFromFile:url];
    }
    
    return self;
}

#pragma mark - KVC

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (value == nil) {
        if ([self.additionals valueForKey:key])
            [self.additionals removeObjectForKey:key];
        
        if ([self.dark valueForKey:key])
            [self.dark removeObjectForKey:key];
    }
    else
        [self.additionals setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id val = [(self.isDark ? self.dark : self.additionals) valueForKey:key];
    
    return val;
}

- (id)valueForKey:(NSString *)key
{
    id val = [super valueForKey:key];
    
    if (!val || [val isKindOfClass:NSDictionary.class]) {
        val = val ?: [self valueForUndefinedKey:key];
        
        // since we're here, it's possible we have the P3 colour as well. Check
        if ([val isKindOfClass:NSDictionary.class]) {
            // check the device screenspace
            
            if ([val valueForKey:@"p3"] && UIApplication.sharedApplication.keyWindow.rootViewController.view.traitCollection.displayGamut == UIDisplayGamutP3) {
                return [val valueForKey:@"p3"];
            }
            else
                return [val valueForKey:@"rgb"];
        }
        
        return val;
        
    }
    
    return val;
}

#pragma mark - Instance Methods

- (void)loadColorsFromFile:(NSURL *)path
{
    [self loadColorsFromFile:path forDark:NO];
}

- (void)loadColorsFromFile:(NSURL *)path forDark:(BOOL)forDark
{
    
    if(!path)
        return;
    
    NSData *contents =  [[NSData alloc] initWithContentsOfFile:path.path];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:contents options:kNilOptions error:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
       
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([obj isKindOfClass:NSString.class]) {
            UIColor *color = [UIColor colorFromHex:obj];
            
            if (forDark)
                [strongSelf.dark setValue:color forKey:key];
            else
                [strongSelf.additionals setValue:color forKey:key];
        }
        else if ([obj isKindOfClass:NSDictionary.class]) {
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
            
            if (forDark)
                [strongSelf.dark setValue:setDict.copy forKey:key];
            else
                [strongSelf.additionals setValue:setDict.copy forKey:key];
        }
        
    }];
    
    if (!forDark) {
        // check if a dark theme is available at the same path
        NSString *darkPath = path.path;
        darkPath = [darkPath stringByReplacingOccurrencesOfString:@".json" withString:@"-dark.json"];
        
        if ([NSFileManager.defaultManager fileExistsAtPath:darkPath]) {
            NSURL *darkURL = [NSURL URLWithString:darkPath];
            
            _dark = @{}.mutableCopy;
            
            [self loadColorsFromFile:darkURL forDark:YES];
        }
        else {
            _dark = nil;
        }
    }
    
}

#pragma mark - Setters

- (void)setAutoUpdatingTheme:(BOOL)autoUpdatingTheme
{
    _autoUpdatingTheme = autoUpdatingTheme;
    
    if (_autoUpdatingTheme && self.dark && self.dark.allKeys.count) {
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didChangeBrightness:) name:UIScreenBrightnessDidChangeNotification object:nil];
        _brightnessNoteRegistered = YES;
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf didChangeBrightness:nil];
        });
    }
    else if (_brightnessNoteRegistered) {
        [NSNotificationCenter.defaultCenter removeObserver:self name:UIScreenBrightnessDidChangeNotification object:nil];
        _brightnessNoteRegistered = NO;
    }
}

#pragma mark - Notifications

- (void)didChangeBrightness:(NSNotification * _Nullable)note {
    
    BOOL newVal = UIScreen.mainScreen.brightness <= 0.4f;
    BOOL fireNotification = newVal != _useDark;
    
    if (fireNotification) {
        _useDark = newVal;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSNotificationCenter.defaultCenter postNotificationName:ThemeNeedsUpdateNotification object:nil];
        });
    }
}

@end
