//
//  Theme.m
//  DZThemeKit
//
//  Created by Nikhil Nigade on 01/05/18.
//  Copyright © 2018 Dezine Zync Studios. All rights reserved.
//

#import "Theme.h"

@interface Theme ()

@property (nonatomic, copy, readwrite) NSString *name;

@property (nonatomic, strong) NSMutableDictionary *backingStore;

@property (nonatomic, strong) NSMutableDictionary *darkBackingStore NS_AVAILABLE_IOS(13.0);

@property (nonatomic, strong) NSMutableDictionary *lightBackingStore NS_AVAILABLE_IOS(13.0);

@end

@implementation Theme

- (instancetype)init {
    if (self = [super init]) {
        self.backingStore = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)updateAppearances {
    
    if (self.tintColor) {
        [UIApplication.sharedApplication.keyWindow setTintColor:self.tintColor];
    }
    
    if (self.tableColor) {
        [[UITableView appearance] setBackgroundColor:self.tableColor];
    }
    
    if (self.borderColor) {
        [[UITableView appearance] setSeparatorColor:self.borderColor];
    }
    
}

- (void)setSupportsDarkMode:(BOOL)supportsDarkMode {
    
    if (_supportsDarkMode == supportsDarkMode) {
        return;
    }
    
    _supportsDarkMode = supportsDarkMode;
    
    if (_supportsDarkMode == YES) {
        // as this is created only after the backingStore is created
        // we know the exact count of items it will hold.
        _darkBackingStore = [[NSMutableDictionary alloc] initWithCapacity:self.backingStore.allKeys.count];
    }
    
}

#pragma mark - KVC

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([value isKindOfClass:NSDictionary.class] && [key containsString:@"Color"]) {
        
        if ([UIApplication.sharedApplication.windows firstObject].traitCollection.displayGamut == UIDisplayGamutP3) {
            value = [(NSDictionary *)value valueForKey:@"p3"];
        }
        else {
            value = [(NSDictionary *)value valueForKey:@"rgb"];
        }
        
    }
    
    if (@available(iOS 13, *)) {
        if (self.updatingDarkBackingStore) {
            [self.darkBackingStore setValue:value forKey:key];
        }
        else {
            [super setValue:value forKey:key];
        }
    }
    else {
        [super setValue:value forKey:key];
    }
    
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    
    if (@available(iOS 13, *)) {
        if (self.updatingDarkBackingStore && [keyPath containsString:@"Color"]) {
            [self.darkBackingStore setValue:value forKey:keyPath];
        }
        else {
            [super setValue:value forKeyPath:keyPath];
        }
    }
    else {
        [super setValue:value forKeyPath:keyPath];
    }
    
}

- (id)valueForKeyPath:(NSString *)keyPath {
    
    if (@available(iOS 13, *)) {
        
        if (self.supportsDarkMode && UIApplication.sharedApplication.keyWindow.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark && [keyPath containsString:@"color"]) {
            return [self.darkBackingStore valueForKey:keyPath];
        }
        
    }
    
    return [super valueForKeyPath:keyPath];
    
}

- (id)valueForKey:(NSString *)key {
    
    if (@available(iOS 13, *)) {
        
        if (self.supportsDarkMode == YES && UIApplication.sharedApplication.keyWindow.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark && [key containsString:@"color"]) {
            return [self.darkBackingStore valueForKey:key];
        }
        
    }
    
    return [super valueForKey:key];
    
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
    
    if (@available(iOS 13, *)) {
        if (self.updatingDarkBackingStore) {
            [self.darkBackingStore setValue:value forKey:key];
        }
    }
    else {
        [self.backingStore setValue:value forKey:key];
    }
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    id val = nil;
    
    if (@available(iOS 13, *)) {
        
        if (self.supportsDarkMode == YES) {
            if (UIApplication.sharedApplication.keyWindow.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                val = [self.backingStore valueForKey:key];
            }
            else {
                val = [self.darkBackingStore valueForKey:key];
            }
        }
        else {
            val = [self.backingStore valueForKey:key];
        }
        
    }
    else {
        val = [self.backingStore valueForKey:key];
    }
    
    if (([key containsString:@"Color"] || [key containsString:@"Colour"]) && [val isKindOfClass:NSDictionary.class]) {
        if ([UIApplication.sharedApplication.windows firstObject].traitCollection.displayGamut == UIDisplayGamutP3) {
            return [(NSDictionary *)val valueForKey:@"p3"];
        }
        
        return [(NSDictionary *)val valueForKey:@"rgb"];
    }
    
    return val;
}

- (void)setBOOL:(BOOL)value forKey:(NSString *)key {
    
    [self setValue:@(value) forKey:key];
    
}

- (BOOL)boolForKey:(NSString *)key {
    
    id obj = [self valueForKey:key];
    
    if (obj) {
        return [obj boolValue];
    }
    
    return NO;
    
}

- (void)setFloat:(CGFloat)value forKey:(NSString *)key {
    
    [self setValue:@(value) forKey:key];
    
}

- (CGFloat)floatForKey:(NSString *)key {
    
    id obj = [self valueForKey:key];
    
    if (obj) {
        return [obj doubleValue];
    }
    
    return 0.f;
    
}

#pragma mark -

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
- (void)updateWithDynamicColors:(NSArray <NSString *> *)colorKeys {
    
    if (colorKeys == nil || colorKeys.count == 0) {
        return;
    }
    
    if (self.supportsDarkMode == NO) {
        return;
    }
    
    [colorKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIColor *lightColor = [self.lightBackingStore valueForKey:key];
        UIColor *darkColor  = [self.darkBackingStore valueForKey:key];
        
        // if both are UIDynamicSystemColors, then use the light variant instead of creating an instance ourseleves
        UIColor *color = nil;
        Class classToCheck = NSClassFromString(@"UIDynamicSystemColor");
        
        if (lightColor != nil && [lightColor isKindOfClass:classToCheck]
            && darkColor != nil && [darkColor isKindOfClass:classToCheck]) {
            
            color = lightColor;
            
        }
        else {
            color = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
                
                if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                    return [self.darkBackingStore valueForKey:key];
                }
                
                return [self.lightBackingStore valueForKey:key];
                
            }];
        }
        
        if ([self valueForKeyPath:key] != nil) {
            [self setValue:color forKeyPath:key];
        }
        else {
            [self.backingStore setValue:color forKey:key];
        }
        
    }];
    
}
#endif

@end
