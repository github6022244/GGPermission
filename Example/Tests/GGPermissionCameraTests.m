//
//  GGPermissionCameraTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionCameraHandler.h"
#import "GGPermissionDefine.h"
#import <AVFoundation/AVFoundation.h>

@interface GGPermissionCameraHandler (Test)
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
@end

@interface GGPermissionCameraTests : XCTestCase
@property (nonatomic, strong) GGPermissionCameraHandler *handler;
@end

@implementation GGPermissionCameraTests

- (void)setUp {
    self.handler = [[GGPermissionCameraHandler alloc] init];
    NSLog(@"   [Camera] handler 初始化完成");
}

- (void)testGrantedForAuthorized {
    NSLog(@"▶️ [Camera] testGrantedForAuthorized");
    NSNumber *code = @(AVAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Authorized), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Camera] Authorized 判为已授权");
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Camera] testNotGrantedForDenied");
    NSNumber *code = @(AVAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Camera] Denied 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Camera] testNotGrantedForNotDetermined");
    NSNumber *code = @(AVAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Camera] NotDetermined 判为未授权");
}

- (void)testDeniedOrRestricted {
    NSLog(@"▶️ [Camera] testDeniedOrRestricted");
    NSNumber *denied = @(AVAuthorizationStatusDenied);
    NSNumber *restricted = @(AVAuthorizationStatusRestricted);
    NSNumber *authorized = @(AVAuthorizationStatusAuthorized);

    NSLog(@"   Denied → %@", [self.handler isDeniedOrRestrictedForStatus:denied] ? @"YES" : @"NO");
    NSLog(@"   Restricted → %@", [self.handler isDeniedOrRestrictedForStatus:restricted] ? @"YES" : @"NO");
    NSLog(@"   Authorized → %@", [self.handler isDeniedOrRestrictedForStatus:authorized] ? @"YES" : @"NO");

    XCTAssertTrue([self.handler isDeniedOrRestrictedForStatus:denied]);
    XCTAssertTrue([self.handler isDeniedOrRestrictedForStatus:restricted]);
    XCTAssertFalse([self.handler isDeniedOrRestrictedForStatus:authorized]);
    NSLog(@"✅ [Camera] Denied/Restricted 判断验证通过");
}

@end
