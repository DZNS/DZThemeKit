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

@interface ThemeKit ()

@property (nonatomic, strong) NSMutableDictionary *additionals;

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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if (value == nil) {
        if ([self.additionals valueForKey:key])
            [self.additionals removeObjectForKey:key];
    }
    else
        [self.additionals setValue:value forKey:key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    id val = [self.additionals valueForKey:key];
    
    return val;
}

#pragma mark -

- (void)loadColorsFromFile:(NSURL *)path
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
            
            [strongSelf setValue:color forKeyPath:key];
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
                else if ([p3val isKindOfClass:NSNumber.class]) {
                    // convert rgb color to p3
                    UIColor *p3color = [UIColor colorFromHex:[subdict valueForKey:@"rgb"] p3:YES fromRGB:YES];
                    [setDict setObject:p3color forKey:@"p3"];
                }
            }
        }
        
    }];
    
    NSLog(@"%@", [self valueForKey:@"customColor"]);
    
}

@end
