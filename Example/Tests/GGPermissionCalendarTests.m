//
//  GGPermissionCalendarTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionCalendarHandler.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import <EventKit/EventKit.h>

#pragma mark - 暴露私有 hook

@interface GGPermissionCalendarHandler (Test)
@property (nonatomic, assign) GGPermissionType currentCalendarType;
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (nullable NSNumber *)currentSystemStatus;
- (GGPermissionBaseRequest *)createRequest;
- (NSString *)guideTipsForType:(GGPermissionType)type;
@end

#pragma mark - 测试类

@interface GGPermissionCalendarTests : XCTestCase
@property (nonatomic, strong) GGPermissionCalendarHandler *handler;
@end

@implementation GGPermissionCalendarTests

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionCalendarHandler alloc] init];
    NSLog(@"   [Calendar] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Calendar] handler 已释放");
    [super tearDown];
}

#pragma mark - FullAccess 状态

- (void)testFullAccessGrantedForFullAccess {
    NSLog(@"▶️ [Calendar] testFullAccessGrantedForFullAccess");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    if (@available(iOS 17.0, *)) {
        NSNumber *code = @(EKAuthorizationStatusFullAccess);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   FullAccess + status = %@ (FullAccess), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertTrue(granted);
        NSLog(@"✅ [Calendar] FullAccess + FullAccess 判为已授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 17，无 FullAccess 枚举");
    }
}

- (void)testFullAccessNotGrantedForWriteOnly {
    NSLog(@"▶️ [Calendar] testFullAccessNotGrantedForWriteOnly");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    if (@available(iOS 17.0, *)) {
        NSNumber *code = @(EKAuthorizationStatusWriteOnly);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   FullAccess + status = %@ (WriteOnly), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertFalse(granted, @"FullAccess 请求不应接受 WriteOnly");
        NSLog(@"✅ [Calendar] FullAccess + WriteOnly 判为未授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 17");
    }
}

- (void)testFullAccessDeniedOrRestrictedForWriteOnly {
    NSLog(@"▶️ [Calendar] testFullAccessDeniedOrRestrictedForWriteOnly");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    if (@available(iOS 17.0, *)) {
        NSNumber *code = @(EKAuthorizationStatusWriteOnly);
        BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
        NSLog(@"   FullAccess + WriteOnly, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
        XCTAssertTrue(result, @"FullAccess 请求下 WriteOnly 应引导设置");
        NSLog(@"✅ [Calendar] FullAccess + WriteOnly 判为需引导");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 17");
    }
}

#pragma mark - WriteOnly 状态

- (void)testWriteOnlyGrantedForWriteOnly {
    NSLog(@"▶️ [Calendar] testWriteOnlyGrantedForWriteOnly");
    self.handler.currentCalendarType = GGPermissionTypeCalendarWriteOnly;
    if (@available(iOS 17.0, *)) {
        NSNumber *code = @(EKAuthorizationStatusWriteOnly);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   WriteOnly + status = %@ (WriteOnly), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertTrue(granted);
        NSLog(@"✅ [Calendar] WriteOnly + WriteOnly 判为已授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 17");
    }
}

- (void)testWriteOnlyGrantedForFullAccess {
    NSLog(@"▶️ [Calendar] testWriteOnlyGrantedForFullAccess");
    self.handler.currentCalendarType = GGPermissionTypeCalendarWriteOnly;
    if (@available(iOS 17.0, *)) {
        NSNumber *code = @(EKAuthorizationStatusFullAccess);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   WriteOnly + status = %@ (FullAccess), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertTrue(granted, @"WriteOnly 请求下 FullAccess 也算已授权");
        NSLog(@"✅ [Calendar] WriteOnly + FullAccess 判为已授权");
    } else {
        NSLog(@"   ⏭ 跳过：iOS < 17");
    }
}

#pragma mark - 通用状态

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Calendar] testNotGrantedForDenied");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Calendar] Denied 判为未授权");
}

- (void)testNotGrantedForRestricted {
    NSLog(@"▶️ [Calendar] testNotGrantedForRestricted");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusRestricted);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Restricted), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Calendar] Restricted 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Calendar] testNotGrantedForNotDetermined");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Calendar] NotDetermined 判为未授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Calendar] testNotGrantedForNegativeCode");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Calendar] 负错误码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus:

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Calendar] testDeniedOrRestrictedForDenied");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusDenied);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   Denied, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
    XCTAssertTrue(result);
    NSLog(@"✅ [Calendar] Denied 判为已拒绝/受限");
}

- (void)testDeniedOrRestrictedForRestricted {
    NSLog(@"▶️ [Calendar] testDeniedOrRestrictedForRestricted");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusRestricted);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   Restricted, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
    XCTAssertTrue(result);
    NSLog(@"✅ [Calendar] Restricted 判为已拒绝/受限");
}

- (void)testNotDeniedForAuthorized {
    NSLog(@"▶️ [Calendar] testNotDeniedForAuthorized");
    self.handler.currentCalendarType = GGPermissionTypeCalendarFullAccess;
    NSNumber *code = @(EKAuthorizationStatusFullAccess);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   FullAccess, isDeniedOrRestricted = %@", result ? @"YES" : @"NO");
    XCTAssertFalse(result);
    NSLog(@"✅ [Calendar] FullAccess 不算已拒绝/受限");
}

#pragma mark - guideTips

- (void)testGuideTipsForFullAccess {
    NSLog(@"▶️ [Calendar] testGuideTipsForFullAccess");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeCalendarFullAccess];
    NSLog(@"   FullAccess guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Calendar] FullAccess 引导文案非空");
}

- (void)testGuideTipsForWriteOnly {
    NSLog(@"▶️ [Calendar] testGuideTipsForWriteOnly");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeCalendarWriteOnly];
    NSLog(@"   WriteOnly guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Calendar] WriteOnly 引导文案非空");
}

#pragma mark - createRequest

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Calendar] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req);
    NSLog(@"✅ [Calendar] createRequest 返回有效 Request");
}

@end
