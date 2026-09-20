//
//  GGPermissionLocationTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionLocationHandler.h"
#import "GGPermissionDefine.h"
#import <CoreLocation/CoreLocation.h>

@interface GGPermissionLocationHandler (Test)
- (nullable NSNumber *)currentSystemStatus;
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
@end

@interface GGPermissionLocationTests : XCTestCase
@property (nonatomic, strong) GGPermissionLocationHandler *handler;
@end

@implementation GGPermissionLocationTests

- (void)setUp {
    self.handler = [[GGPermissionLocationHandler alloc] init];
    NSLog(@"   [Location] handler 初始化完成");
}

#pragma mark - isGrantedForStatus

- (void)testGrantedForAuthorizedAlways {
    NSLog(@"▶️ [Location] testGrantedForAuthorizedAlways");
    NSNumber *code = @(kCLAuthorizationStatusAuthorizedAlways);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (AuthorizedAlways), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Location] AuthorizedAlways 判为已授权");
}

- (void)testGrantedForAuthorizedWhenInUse {
    NSLog(@"▶️ [Location] testGrantedForAuthorizedWhenInUse");
    NSNumber *code = @(kCLAuthorizationStatusAuthorizedWhenInUse);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (AuthorizedWhenInUse), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Location] AuthorizedWhenInUse 判为已授权");
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Location] testNotGrantedForDenied");
    NSNumber *code = @(kCLAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Location] Denied 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Location] testNotGrantedForNotDetermined");
    NSNumber *code = @(kCLAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Location] NotDetermined 判为未授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Location] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Location] 负错误码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Location] testDeniedOrRestrictedForDenied");
    NSNumber *code = @(kCLAuthorizationStatusDenied);
    BOOL denied = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Denied), isDeniedOrRestricted = %@", code, denied ? @"YES" : @"NO");
    XCTAssertTrue(denied);
    NSLog(@"✅ [Location] Denied 判为已拒绝/受限");
}

- (void)testDeniedOrRestrictedForRestricted {
    NSLog(@"▶️ [Location] testDeniedOrRestrictedForRestricted");
    NSNumber *code = @(kCLAuthorizationStatusRestricted);
    BOOL denied = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Restricted), isDeniedOrRestricted = %@", code, denied ? @"YES" : @"NO");
    XCTAssertTrue(denied);
    NSLog(@"✅ [Location] Restricted 判为已拒绝/受限");
}

- (void)testNotDeniedForAuthorized {
    NSLog(@"▶️ [Location] testNotDeniedForAuthorized");
    NSNumber *code = @(kCLAuthorizationStatusAuthorizedAlways);
    BOOL denied = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (AuthorizedAlways), isDeniedOrRestricted = %@", code, denied ? @"YES" : @"NO");
    XCTAssertFalse(denied);
    NSLog(@"✅ [Location] AuthorizedAlways 不算已拒绝/受限");
}

#pragma mark - 静态查询

- (void)testIsAuthorizedStatic {
    NSLog(@"▶️ [Location] testIsAuthorizedStatic");
    BOOL authorized = [GGPermissionLocationHandler isAuthorized];
    NSLog(@"   [GGPermissionLocationHandler isAuthorized] = %@", authorized ? @"YES" : @"NO");
    // 不断言具体值，取决于运行环境
    NSLog(@"✅ [Location] isAuthorized 静态查询无崩溃");
}

@end
