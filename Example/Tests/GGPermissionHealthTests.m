//
//  GGPermissionHealthTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionHealthHandler.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import <GGPermission.h>
#import <HealthKit/HealthKit.h>

#pragma mark - 暴露私有 hook 方法（测试用）

@interface GGPermissionHealthHandler (Test)
@property (nonatomic, assign) GGPermissionType currentHealthType;
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (nullable NSNumber *)currentSystemStatus;
- (GGPermissionBaseRequest *)createRequest;
- (NSString *)guideTipsForType:(GGPermissionType)type;
@end

#pragma mark - 测试类

@interface GGPermissionHealthTests : XCTestCase

@property (nonatomic, strong) GGPermissionHealthHandler *handler;

@end

@implementation GGPermissionHealthTests

#pragma mark - Life Cycle

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionHealthHandler alloc] init];
    NSLog(@"   [Health] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Health] handler 已释放");
    [super tearDown];
}

#pragma mark - isGrantedForStatus:

- (void)testGrantedForCode0 {
    NSLog(@"▶️ [Health] testGrantedForCode0");
    NSNumber *code = @(0);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (弹窗流程完成), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted, @"0 应判为已授权");
    NSLog(@"✅ [Health] 0 判为已授权");
}

- (void)testGrantedForPositiveCode {
    NSLog(@"▶️ [Health] testGrantedForPositiveCode");
    NSNumber *code = @(1);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (正数), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted, @"正数应判为已授权");
    NSLog(@"✅ [Health] 正数判为已授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Health] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorUnknown);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Unknown = -1), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"负错误码应判为未授权");
    NSLog(@"✅ [Health] 负错误码判为未授权");
}

- (void)testNotGrantedForServiceDisabled {
    NSLog(@"▶️ [Health] testNotGrantedForServiceDisabled");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled = -2), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Health] ServiceDisabled 判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus:

- (void)testNotDeniedForAnyCode {
    NSLog(@"▶️ [Health] testNotDeniedForAnyCode");
    // HealthKit 无法同步查询状态，isDeniedOrRestrictedForStatus: 永远返回 NO
    NSArray<NSNumber *> *codes = @[@(0), @(1), @(2),
                                   @(GGPermissionErrorUnknown),
                                   @(GGPermissionErrorServiceDisabled)];
    for (NSNumber *code in codes) {
        BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
        NSLog(@"   status = %@, isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
        XCTAssertFalse(result, @"HealthKit 不应判为已拒绝/受限（无法同步查询）");
    }
    NSLog(@"✅ [Health] isDeniedOrRestricted 永远返回 NO（符合 HealthKit 设计）");
}

#pragma mark - currentSystemStatus

- (void)testCurrentSystemStatusReturnsNil {
    NSLog(@"▶️ [Health] testCurrentSystemStatusReturnsNil");
    NSNumber *status = [self.handler currentSystemStatus];
    NSLog(@"   currentSystemStatus = %@", status);
    XCTAssertNil(status, @"HealthKit 无法同步查询状态，应返回 nil");
    NSLog(@"✅ [Health] currentSystemStatus 返回 nil（符合 HealthKit 设计）");
}

#pragma mark - guideTips

- (void)testGuideTipsForHealth {
    NSLog(@"▶️ [Health] testGuideTipsForHealth");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeHealth];
    NSLog(@"   Health guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Health] Health 引导文案非空");
}

- (void)testGuideTipsForHealthSteps {
    NSLog(@"▶️ [Health] testGuideTipsForHealthSteps");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeHealthSteps];
    NSLog(@"   Steps guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Health] Steps 引导文案非空");
}

- (void)testGuideTipsForHealthHeartRate {
    NSLog(@"▶️ [Health] testGuideTipsForHealthHeartRate");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeHealthHeartRate];
    NSLog(@"   HeartRate guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Health] HeartRate 引导文案非空");
}

- (void)testGuideTipsForHealthSleep {
    NSLog(@"▶️ [Health] testGuideTipsForHealthSleep");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeHealthSleep];
    NSLog(@"   Sleep guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Health] Sleep 引导文案非空");
}

- (void)testGuideTipsForHealthWorkout {
    NSLog(@"▶️ [Health] testGuideTipsForHealthWorkout");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeHealthWorkout];
    NSLog(@"   Workout guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Health] Workout 引导文案非空");
}

#pragma mark - createRequest

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Health] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req, @"createRequest 不应返回 nil");
    NSLog(@"✅ [Health] createRequest 返回有效 Request");
}

#pragma mark - 端到端（综合）

- (void)testRequestPermissionHealthEndToEnd {
    NSLog(@"▶️ [Health] testRequestPermissionHealthEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"健康综合权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeHealth
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   [Health] 回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        NSLog(@"   说明：%@", [self descForHealthStatus:statusCode.integerValue]);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Health] 综合权限端到端完成");
}

#pragma mark - 端到端（步数）

- (void)testRequestPermissionStepsEndToEnd {
    NSLog(@"▶️ [Health] testRequestPermissionStepsEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"健康步数权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeHealthSteps
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   [Health-Steps] 回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Health] 步数权限端到端完成");
}

#pragma mark - 端到端（心率）

- (void)testRequestPermissionHeartRateEndToEnd {
    NSLog(@"▶️ [Health] testRequestPermissionHeartRateEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"健康心率权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeHealthHeartRate
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   [Health-HeartRate] 回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Health] 心率权限端到端完成");
}

#pragma mark - 端到端（睡眠）

- (void)testRequestPermissionSleepEndToEnd {
    NSLog(@"▶️ [Health] testRequestPermissionSleepEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"健康睡眠权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeHealthSleep
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   [Health-Sleep] 回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Health] 睡眠权限端到端完成");
}

#pragma mark - 端到端（锻炼）

- (void)testRequestPermissionWorkoutEndToEnd {
    NSLog(@"▶️ [Health] testRequestPermissionWorkoutEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"健康锻炼权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeHealthWorkout
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   [Health-Workout] 回调 granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Health] 锻炼权限端到端完成");
}

#pragma mark - 辅助

- (NSString *)descForHealthStatus:(NSInteger)code {
    if (code < 0) {
        switch (code) {
            case GGPermissionErrorUnknown:            return @"Unknown（可能是 entitlement 缺失）";
            case GGPermissionErrorServiceDisabled:    return @"ServiceDisabled（设备不支持 HealthKit）";
            case GGPermissionErrorTimeout:            return @"Timeout";
            case GGPermissionErrorNoTopViewController:return @"NoTopVC";
            default:                                  return @"其他内部错误";
        }
    }
    switch (code) {
        case 0:  return @"弹窗流程已完成（不代表所有类型被同意，需读数据时判断）";
        case 1:  return @"用户拒绝 / 请求失败";
        default: return [NSString stringWithFormat:@"未知状态（%ld）", (long)code];
    }
}

@end
