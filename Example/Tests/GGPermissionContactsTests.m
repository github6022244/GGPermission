//
//  GGPermissionContactsTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GGPermissionContactsHandler.h>
#import <GGPermission.h>
#import <GGPermissionDefine.h>
#import <Contacts/Contacts.h>

#pragma mark - 私有方法暴露（测试用）

@interface GGPermissionContactsHandler (Test)
- (nullable NSNumber *)currentSystemStatus;
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (NSString *)guideTipsForType:(GGPermissionType)type;
- (GGPermissionBaseRequest *)createRequest;
@end

#pragma mark - 测试类

@interface GGPermissionContactsTests : XCTestCase

@property (nonatomic, strong) GGPermissionContactsHandler *handler;

@end

@implementation GGPermissionContactsTests

#pragma mark - Life Cycle

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionContactsHandler alloc] init];
    NSLog(@"   [Contacts] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Contacts] handler 已释放");
    [super tearDown];
}

#pragma mark - isGrantedForStatus: 状态判断

- (void)testGrantedForAuthorized {
    NSLog(@"▶️ [Contacts] testGrantedForAuthorized");
    NSNumber *code = @(CNAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Authorized = 3), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted, @"Authorized 应判为已授权");
    NSLog(@"✅ [Contacts] Authorized 判为已授权");
}

- (void)testGrantedForLimitedOnIOS18 {
    NSLog(@"▶️ [Contacts] testGrantedForLimitedOnIOS18");
    if (@available(iOS 18.0, *)) {
        NSNumber *code = @(CNAuthorizationStatusLimited);
        BOOL granted = [self.handler isGrantedForStatus:code];
        NSLog(@"   status = %@ (Limited = 4, iOS 18+), granted = %@", code, granted ? @"YES" : @"NO");
        XCTAssertTrue(granted, @"iOS 18+ Limited 应算授权");
        NSLog(@"✅ [Contacts] Limited (iOS 18+) 判为已授权");
    } else {
        NSLog(@"   ⏭ 跳过：当前 iOS < 18.0，无 Limited 枚举");
    }
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Contacts] testNotGrantedForDenied");
    NSNumber *code = @(CNAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied = 2), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"Denied 应判为未授权");
    NSLog(@"✅ [Contacts] Denied 判为未授权");
}

- (void)testNotGrantedForRestricted {
    NSLog(@"▶️ [Contacts] testNotGrantedForRestricted");
    NSNumber *code = @(CNAuthorizationStatusRestricted);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Restricted = 1), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"Restricted 应判为未授权");
    NSLog(@"✅ [Contacts] Restricted 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Contacts] testNotGrantedForNotDetermined");
    NSNumber *code = @(CNAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined = 0), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"NotDetermined 应判为未授权");
    NSLog(@"✅ [Contacts] NotDetermined 判为未授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Contacts] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled = -2), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"负错误码应判为未授权");
    NSLog(@"✅ [Contacts] 负错误码判为未授权");
}

- (void)testNotGrantedForUnknownCode {
    NSLog(@"▶️ [Contacts] testNotGrantedForUnknownCode");
    NSNumber *code = @(999);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (未知大数值), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"未知状态码应判为未授权");
    NSLog(@"✅ [Contacts] 未知状态码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus: 拒绝/受限判断

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Contacts] testDeniedOrRestrictedForDenied");
    NSNumber *code = @(CNAuthorizationStatusDenied);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Denied = 2), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertTrue(result, @"Denied 应判为已拒绝/受限");
    NSLog(@"✅ [Contacts] Denied 判为已拒绝/受限");
}

- (void)testDeniedOrRestrictedForRestricted {
    NSLog(@"▶️ [Contacts] testDeniedOrRestrictedForRestricted");
    NSNumber *code = @(CNAuthorizationStatusRestricted);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Restricted = 1), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertTrue(result, @"Restricted 应判为已拒绝/受限");
    NSLog(@"✅ [Contacts] Restricted 判为已拒绝/受限");
}

- (void)testNotDeniedForAuthorized {
    NSLog(@"▶️ [Contacts] testNotDeniedForAuthorized");
    NSNumber *code = @(CNAuthorizationStatusAuthorized);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Authorized = 3), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result, @"Authorized 不应判为已拒绝/受限");
    NSLog(@"✅ [Contacts] Authorized 不算已拒绝/受限");
}

- (void)testNotDeniedForNotDetermined {
    NSLog(@"▶️ [Contacts] testNotDeniedForNotDetermined");
    NSNumber *code = @(CNAuthorizationStatusNotDetermined);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined = 0), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result, @"NotDetermined 不应判为已拒绝/受限");
    NSLog(@"✅ [Contacts] NotDetermined 不算已拒绝/受限");
}

- (void)testNotDeniedForNegativeCode {
    NSLog(@"▶️ [Contacts] testNotDeniedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled = -2), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result, @"负错误码不应判为已拒绝/受限");
    NSLog(@"✅ [Contacts] 负错误码不算已拒绝/受限");
}

#pragma mark - currentSystemStatus 读取

- (void)testCurrentSystemStatusReturnsValidValue {
    NSLog(@"▶️ [Contacts] testCurrentSystemStatusReturnsValidValue");
    NSNumber *status = [self.handler currentSystemStatus];
    NSLog(@"   currentSystemStatus = %@", status);
    XCTAssertNotNil(status, @"currentSystemStatus 不应返回 nil");
    NSLog(@"✅ [Contacts] currentSystemStatus 返回有效值");
}

- (void)testCurrentSystemStatusMatchesSystem {
    NSLog(@"▶️ [Contacts] testCurrentSystemStatusMatchesSystem");
    NSNumber *handlerStatus = [self.handler currentSystemStatus];
    CNAuthorizationStatus systemStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    NSLog(@"   handler status = %@, system status = %ld", handlerStatus, (long)systemStatus);
    XCTAssertEqual(handlerStatus.integerValue, (NSInteger)systemStatus,
                   @"handler 返回的状态应与系统一致");
    NSLog(@"✅ [Contacts] currentSystemStatus 与系统状态一致");
}

#pragma mark - guideTipsForType:

- (void)testGuideTipsForContacts {
    NSLog(@"▶️ [Contacts] testGuideTipsForContacts");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeContacts];
    NSLog(@"   guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0, @"引导文案不应为空");
    NSLog(@"✅ [Contacts] 引导文案非空");
}

#pragma mark - createRequest

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Contacts] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req, @"createRequest 不应返回 nil");
    NSLog(@"✅ [Contacts] createRequest 返回有效 Request");
}

#pragma mark - 端到端：请求权限

- (void)testRequestPermissionEndToEnd {
    NSLog(@"▶️ [Contacts] testRequestPermissionEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"通讯录权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeContacts
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        NSLog(@"   说明：%ld = %@", (long)statusCode.integerValue,
              [self descForContactsStatus:statusCode.integerValue]);
        XCTAssertNotNil(statusCode, @"statusCode 不应为 nil");
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Contacts] 端到端请求完成");
}

#pragma mark - 辅助：状态描述

- (NSString *)descForContactsStatus:(NSInteger)code {
    if (code < 0) {
        switch (code) {
            case GGPermissionErrorUnknown:            return @"Unknown";
            case GGPermissionErrorServiceDisabled:    return @"ServiceDisabled";
            case GGPermissionErrorTimeout:            return @"Timeout";
            case GGPermissionErrorNoTopViewController:return @"NoTopVC";
            default:                                  return @"其他内部错误";
        }
    }
    switch ((CNAuthorizationStatus)code) {
        case CNAuthorizationStatusNotDetermined: return @"未确定";
        case CNAuthorizationStatusRestricted:    return @"受限";
        case CNAuthorizationStatusDenied:        return @"已拒绝";
        case CNAuthorizationStatusAuthorized:    return @"已授权";
        case CNAuthorizationStatusLimited:
            if (@available(iOS 18.0, *)) {
                return @"受限访问（iOS 18+）";
            }
            return @"未知";
        default:                                 return @"未知状态";
    }
}

@end
