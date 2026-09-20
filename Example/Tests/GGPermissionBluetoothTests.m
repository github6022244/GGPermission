//
//  GGPermissionBluetoothTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionBluetoothHandler.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import <CoreBluetooth/CoreBluetooth.h>

#pragma mark - 暴露私有 hook

@interface GGPermissionBluetoothHandler (Test)
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (nullable NSNumber *)currentSystemStatus;
- (GGPermissionBaseRequest *)createRequest;
- (NSString *)guideTipsForType:(GGPermissionType)type;
@end

#pragma mark - 测试类

@interface GGPermissionBluetoothTests : XCTestCase
@property (nonatomic, strong) GGPermissionBluetoothHandler *handler;
@end

@implementation GGPermissionBluetoothTests

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionBluetoothHandler alloc] init];
    NSLog(@"   [Bluetooth] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Bluetooth] handler 已释放");
    [super tearDown];
}

#pragma mark - isGrantedForStatus:

- (void)testGrantedForAllowedAlways {
    NSLog(@"▶️ [Bluetooth] testGrantedForAllowedAlways");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationAllowedAlways);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   status = %@ (AllowedAlways), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertTrue(granted);
        NSLog(@"✅ [Bluetooth] AllowedAlways 判为已授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Bluetooth] testNotGrantedForDenied");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationDenied);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertFalse(granted);
        NSLog(@"✅ [Bluetooth] Denied 判为未授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testNotGrantedForRestricted {
    NSLog(@"▶️ [Bluetooth] testNotGrantedForRestricted");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationRestricted);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   status = %@ (Restricted), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertFalse(granted);
        NSLog(@"✅ [Bluetooth] Restricted 判为未授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Bluetooth] testNotGrantedForNotDetermined");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationNotDetermined);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertFalse(granted);
        NSLog(@"✅ [Bluetooth] NotDetermined 判为未授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Bluetooth] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Bluetooth] 负错误码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus:

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Bluetooth] testDeniedOrRestrictedForDenied");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationDenied);
        BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
        NSLog(@"   Denied, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
        XCTAssertTrue(result);
        NSLog(@"✅ [Bluetooth] Denied 判为已拒绝/受限");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testDeniedOrRestrictedForRestricted {
    NSLog(@"▶️ [Bluetooth] testDeniedOrRestrictedForRestricted");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationRestricted);
        BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
        NSLog(@"   Restricted, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
        XCTAssertTrue(result);
        NSLog(@"✅ [Bluetooth] Restricted 判为已拒绝/受限");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

- (void)testNotDeniedForAllowedAlways {
    NSLog(@"▶️ [Bluetooth] testNotDeniedForAllowedAlways");
    if (@available(iOS 13.0, *)) {
        NSNumber *code = @(CBManagerAuthorizationAllowedAlways);
        BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
        NSLog(@"   AllowedAlways, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
        XCTAssertFalse(result);
        NSLog(@"✅ [Bluetooth] AllowedAlways 不算已拒绝/受限");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 13");
    }
}

#pragma mark - guideTips / createRequest

- (void)testGuideTipsForBluetooth {
    NSLog(@"▶️ [Bluetooth] testGuideTipsForBluetooth");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeBluetooth];
    NSLog(@"   guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Bluetooth] 引导文案非空");
}

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Bluetooth] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req);
    NSLog(@"✅ [Bluetooth] createRequest 返回有效 Request");
}

@end
