//
//  GGPermissionBaseHandlerTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GGPermissionBaseHandler.h>
#import <GGPermissionBaseRequest.h>
#import <GGPermissionDefine.h>
#import <GGPermission.h>

#pragma mark - 测试用 Request 子类

/// 测试专用 Request，不真正发起系统请求
@interface GGTestBaseHandlerRequest : GGPermissionBaseRequest
@end

@implementation GGTestBaseHandlerRequest

- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    NSLog(@"   [GGTestBaseHandlerRequest] startRequest type = %ld", (long)type);
    [self prepareForNewRequest];
    self.callback = callback;
    // 不真正发起系统请求
}

- (void)onCancel {
    NSLog(@"   [GGTestBaseHandlerRequest] onCancel");
}

- (NSNumber *)currentSystemStatus {
    return @(0);
}

@end

#pragma mark - 测试用 Handler 子类

@interface GGTestBaseHandler : GGPermissionBaseHandler
@property (nonatomic, assign) BOOL createRequestCalled;
@property (nonatomic, assign) NSInteger createRequestCount;
@end

@implementation GGTestBaseHandler

- (GGPermissionBaseRequest *)createRequest {
    self.createRequestCalled = YES;
    self.createRequestCount++;
    NSLog(@"   [GGTestBaseHandler] createRequest 第 %ld 次", (long)self.createRequestCount);
    return [[GGTestBaseHandlerRequest alloc] init];   // 返回测试子类
}

- (NSNumber *)currentSystemStatus {
    return @(0);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    return statusCode.integerValue == 3;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    return statusCode.integerValue == 2;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return @"测试文案";
}

@end

#pragma mark - 测试类

@interface GGPermissionBaseHandlerTests : XCTestCase
@end

@implementation GGPermissionBaseHandlerTests

#pragma mark - createRequest

- (void)testStartRequestCreatesRequest {
    NSLog(@"▶️ [BaseHandler] testStartRequestCreatesRequest");
    GGTestBaseHandler *handler = [[GGTestBaseHandler alloc] init];

    NSLog(@"   调用 startRequestWithType");
    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {}];

    NSLog(@"   createRequestCalled = %@", handler.createRequestCalled ? @"YES" : @"NO");
    NSLog(@"   currentRequest = %@", handler.currentRequest);

    XCTAssertTrue(handler.createRequestCalled);
    XCTAssertNotNil(handler.currentRequest);
    NSLog(@"✅ [BaseHandler] createRequest 被调用验证通过");
}

#pragma mark - 连续请求

- (void)testConsecutiveStartCancelsPrevious {
    NSLog(@"▶️ [BaseHandler] testConsecutiveStartCancelsPrevious");
    GGTestBaseHandler *handler = [[GGTestBaseHandler alloc] init];

    NSLog(@"   第一次 startRequest");
    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {}];
    GGPermissionBaseRequest *first = handler.currentRequest;
    NSLog(@"   first = %p, cancelled = %@", first, first.cancelled ? @"YES" : @"NO");

    NSLog(@"   第二次 startRequest");
    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {}];
    GGPermissionBaseRequest *second = handler.currentRequest;
    NSLog(@"   second = %p", second);

    NSLog(@"   旧 Request cancelled = %@", first.cancelled ? @"YES" : @"NO");
    XCTAssertNotEqual(first, second);
    XCTAssertTrue(first.cancelled, @"旧 Request 应被取消");
    NSLog(@"✅ [BaseHandler] 连续请求取消旧 Request 验证通过");
}

#pragma mark - 回调链路

- (void)testRequestCallbackInvokesHandlerBlock {
    NSLog(@"▶️ [BaseHandler] testRequestCallbackInvokesHandlerBlock");
    XCTestExpectation *exp = [self expectationWithDescription:@"回调"];
    GGTestBaseHandler *handler = [[GGTestBaseHandler alloc] init];

    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   ✅ Handler 回调被触发：granted = %@, statusCode = %@",
              granted ? @"YES" : @"NO", statusCode);
        [exp fulfill];
    }];

    // 手动触发 Request 的 executeCallback
    GGPermissionBaseRequest *req = handler.currentRequest;
    NSLog(@"   手动触发 req.executeCallback:YES statusCode:@(3)");
    [req executeCallback:YES statusCode:@(3)];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    NSLog(@"✅ [BaseHandler] 回调链路验证通过");
}

#pragma mark - 旧 Request 回调被忽略

- (void)testOldRequestCallbackIgnored {
    NSLog(@"▶️ [BaseHandler] testOldRequestCallbackIgnored");
    __block BOOL oldCallbackCalled = NO;
    __block NSInteger newCallbackCount = 0;
    GGTestBaseHandler *handler = [[GGTestBaseHandler alloc] init];

    NSLog(@"   第一次 startRequest");
    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        oldCallbackCalled = YES;
        NSLog(@"   ⚠️ 旧回调被触发（不应发生）");
    }];
    GGPermissionBaseRequest *oldReq = handler.currentRequest;

    NSLog(@"   第二次 startRequest");
    [handler startRequestWithType:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        newCallbackCount++;
        NSLog(@"   ✅ 新回调被触发：granted = %@", granted ? @"YES" : @"NO");
    }];

    NSLog(@"   手动触发旧 Request 的 executeCallback");
    [oldReq executeCallback:YES statusCode:@(3)];

    NSLog(@"   手动触发新 Request 的 executeCallback");
    [handler.currentRequest executeCallback:YES statusCode:@(3)];

    NSLog(@"   oldCallbackCalled = %@, newCallbackCount = %ld",
          oldCallbackCalled ? @"YES" : @"NO", (long)newCallbackCount);

    XCTAssertFalse(oldCallbackCalled, @"旧 Request 回调不应被触发");
    XCTAssertEqual(newCallbackCount, 1, @"新 Request 回调应执行一次");
    NSLog(@"✅ [BaseHandler] 旧 Request 回调被忽略验证通过");
}

#pragma mark - 引导设置

- (void)testGuideToSettingInvokesCallback {
    NSLog(@"▶️ [BaseHandler] testGuideToSettingInvokesCallback");
    XCTestExpectation *exp = [self expectationWithDescription:@"引导设置"];
    GGTestBaseHandler *handler = [[GGTestBaseHandler alloc] init];

    // 关闭自动弹窗，直接回调
    [GGPermission shareInstance].autoTipEnable = NO;

    [handler guideToSettingWithType:GGPermissionTypeCamera
                             status:@(2)
                           callback:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   ✅ 引导回调：granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        XCTAssertFalse(granted);
        XCTAssertEqual(statusCode.integerValue, 2);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    NSLog(@"✅ [BaseHandler] 引导设置回调验证通过");
}

@end
