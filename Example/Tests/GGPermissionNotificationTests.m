//
//  GGPermissionNotificationTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionNotificationHandler.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import <GGPermission.h>
#import <UserNotifications/UserNotifications.h>

#pragma mark - 暴露私有 hook 方法

@interface GGPermissionNotificationHandler (Test)
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (GGPermissionBaseRequest *)createRequest;
- (NSString *)guideTipsForType:(GGPermissionType)type;
@end

#pragma mark - 测试类

@interface GGPermissionNotificationTests : XCTestCase
@property (nonatomic, strong) GGPermissionNotificationHandler *handler;
@end

@implementation GGPermissionNotificationTests

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionNotificationHandler alloc] init];
    NSLog(@"   [Notification] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Notification] handler 已释放");
    [super tearDown];
}

#pragma mark - isGrantedForStatus:

- (void)testGrantedForAuthorized {
    NSLog(@"▶️ [Notification] testGrantedForAuthorized");
    NSNumber *code = @(UNAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Authorized), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Notification] Authorized 判为已授权");
}

- (void)testGrantedForProvisional {
    NSLog(@"▶️ [Notification] testGrantedForProvisional");
    NSNumber *code = @(UNAuthorizationStatusProvisional);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Provisional), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted, @"Provisional 应判为已授权");
    NSLog(@"✅ [Notification] Provisional 判为已授权");
}

- (void)testGrantedForEphemeral {
    NSLog(@"▶️ [Notification] testGrantedForEphemeral");
    NSNumber *code = @(UNAuthorizationStatusEphemeral);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Ephemeral), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted, @"Ephemeral 应判为已授权");
    NSLog(@"✅ [Notification] Ephemeral 判为已授权");
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Notification] testNotGrantedForDenied");
    NSNumber *code = @(UNAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Notification] Denied 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Notification] testNotGrantedForNotDetermined");
    NSNumber *code = @(UNAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Notification] NotDetermined 判为未授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Notification] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Notification] 负错误码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus:

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Notification] testDeniedOrRestrictedForDenied");
    NSNumber *code = @(UNAuthorizationStatusDenied);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Denied), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertTrue(result);
    NSLog(@"✅ [Notification] Denied 判为已拒绝/受限");
}

- (void)testNotDeniedForAuthorized {
    NSLog(@"▶️ [Notification] testNotDeniedForAuthorized");
    NSNumber *code = @(UNAuthorizationStatusAuthorized);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Authorized), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result);
    NSLog(@"✅ [Notification] Authorized 不算已拒绝/受限");
}

- (void)testNotDeniedForProvisional {
    NSLog(@"▶️ [Notification] testNotDeniedForProvisional");
    NSNumber *code = @(UNAuthorizationStatusProvisional);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Provisional), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result);
    NSLog(@"✅ [Notification] Provisional 不算已拒绝/受限");
}

#pragma mark - guideTips / createRequest

- (void)testGuideTipsForNotification {
    NSLog(@"▶️ [Notification] testGuideTipsForNotification");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeNotification];
    NSLog(@"   guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Notification] 引导文案非空");
}

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Notification] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req);
    NSLog(@"✅ [Notification] createRequest 返回有效 Request");
}

#pragma mark - 端到端

- (void)testRequestPermissionEndToEnd {
    NSLog(@"▶️ [Notification] testRequestPermissionEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"通知权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeNotification
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   回调 granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        NSLog(@"   说明：%@", [self descForNotificationStatus:statusCode.integerValue]);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Notification] 端到端请求完成");
}

#pragma mark - 辅助

- (NSString *)descForNotificationStatus:(NSInteger)code {
    if (code < 0) {
        switch (code) {
            case GGPermissionErrorUnknown:            return @"Unknown";
            case GGPermissionErrorServiceDisabled:    return @"ServiceDisabled";
            case GGPermissionErrorTimeout:            return @"Timeout";
            case GGPermissionErrorNoTopViewController:return @"NoTopVC";
            default:                                  return @"其他内部错误";
        }
    }
    switch ((UNAuthorizationStatus)code) {
        case UNAuthorizationStatusNotDetermined: return @"未确定";
        case UNAuthorizationStatusDenied:        return @"已拒绝";
        case UNAuthorizationStatusAuthorized:    return @"已授权";
        case UNAuthorizationStatusProvisional:   return @"临时授权（Provisional）";
        case UNAuthorizationStatusEphemeral:     return @"临时授权（Ephemeral）";
        default:                                 return @"未知状态";
    }
}

@end
