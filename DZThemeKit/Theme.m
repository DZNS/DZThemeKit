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
    
    [super setValue:value forKey:key];
    
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
    
    [self.backingStore setValue:value forKey:key];
    
}

- (id)valueForUndefinedKey:(NSString *)key {
    id val = [self.backingStore valueForKey:key];
    
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

@end
