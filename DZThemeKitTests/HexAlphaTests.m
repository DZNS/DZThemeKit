//
//  HexAlphaTests.m
//  DZThemeKitTests
//
//  Created by Nikhil Nigade on 06/11/17.
//  Copyright © 2017 Dezine Zync Studios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UIColor+HexAlpha.h"

@interface HexAlphaTests : XCTestCase

@end

@implementation HexAlphaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWhiteNoAlpha {
    NSString *hex = @"#FFFFFF";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat white, alpha;
    [color getWhite:&white alpha:&alpha];
    
    XCTAssert(white > 0.5f && alpha == 1.f);
}

- (void)testWhiteAlpha {
    NSString *hex = @"#FFFFFF50";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat white, alpha;
    [color getWhite:&white alpha:&alpha];
    
    XCTAssert(white > 0.5f && alpha == 0.5f);
}

- (void)testHalfWhiteAlpha {
    NSString *hex = @"#FFF50";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat white, alpha;
    [color getWhite:&white alpha:&alpha];
    
    XCTAssert(white > 0.5f && alpha == 0.5f);
}

- (void)testRedNoAlpha {
    NSString *hex = @"#FF0000";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat red, alpha;
    [color getRed:&red green:nil blue:nil alpha:&alpha];
    
    XCTAssert(red > 0.5f && alpha == 1.f);
}

- (void)testRedAlpha {
    NSString *hex = @"#FF000050";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat red, alpha;
    [color getRed:&red green:nil blue:nil alpha:&alpha];
    
    XCTAssert(red > 0.5f && alpha == 0.5f);
}

- (void)testHalfRedNoAlpha {
    NSString *hex = @"#F00";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat red, alpha;
    [color getRed:&red green:nil blue:nil alpha:&alpha];
    
    XCTAssert(red > 0.5f && alpha == 1.f);
}

- (void)testHalfRedAlpha {
    NSString *hex = @"#F0050";
    UIColor *color = [UIColor colorFromHex:hex];
    
    CGFloat red, alpha;
    [color getRed:&red green:nil blue:nil alpha:&alpha];
    
    XCTAssert(red > 0.5f && alpha == 0.5f);
}

@end
