//
//  GGPermissionBaseRequestTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"

#pragma mark - 测试子类

@interface GGTestRequest : GGPermissionBaseRequest
@property (nonatomic, assign) BOOL onCancelCalled;
@property (nonatomic, assign) BOOL startRequestCalled;
@property (nonatomic, assign) NSInteger onCancelCallCount;
@end

@implementation GGTestRequest

- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    NSLog(@"   [GGTestRequest] startRequest type = %ld", (long)type);
    self.startRequestCalled = YES;
    [self prepareForNewRequest];
    self.callback = callback;
}

- (void)onCancel {
    self.onCancelCalled = YES;
    self.onCancelCallCount++;
    NSLog(@"   [GGTestRequest] onCancel called, count = %ld", (long)self.onCancelCallCount);
}

- (NSNumber *)currentSystemStatus {
    return @(1);
}

@end

#pragma mark - 测试类

@interface GGPermissionBaseRequestTests : XCTestCase
@end

@implementation GGPermissionBaseRequestTests

#pragma mark - prepareForNewRequest

- (void)testPrepareForNewRequestResetsState {
    NSLog(@"▶️ [BaseRequest] testPrepareForNewRequestResetsState");
    GGTestRequest *req = [[GGTestRequest alloc] init];
    NSLog(@"   新建 req = %@", req);

    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {}];

    NSLog(@"   callback = %@", req.callback ? @"非 nil" : @"nil");
    NSLog(@"   cancelled = %@", req.cancelled ? @"YES" : @"NO");
    NSLog(@"   isCallbackExecuted = %@", req.isCallbackExecuted ? @"YES" : @"NO");

    XCTAssertNotNil(req.callback);
    XCTAssertFalse(req.cancelled);
    XCTAssertFalse(req.isCallbackExecuted);
    NSLog(@"✅ [BaseRequest] 状态重置验证通过");
}

#pragma mark - executeCallback

- (void)testExecuteCallbackTriggersBlock {
    NSLog(@"▶️ [BaseRequest] testExecuteCallbackTriggersBlock");
    XCTestExpectation *exp = [self expectationWithDescription:@"回调"];
    GGTestRequest *req = [[GGTestRequest alloc] init];

    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   ✅ 回调被触发：granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        XCTAssertTrue(granted);
        XCTAssertEqual(statusCode.integerValue, 1);
        [exp fulfill];
    }];

    NSLog(@"   手动调用 executeCallback:YES statusCode:@(1)");
    [req executeCallback:YES statusCode:@(1)];
    [self waitForExpectationsWithTimeout:1 handler:nil];
    NSLog(@"✅ [BaseRequest] executeCallback 触发 block 验证通过");
}

- (void)testExecuteCallbackOnlyOnce {
    NSLog(@"▶️ [BaseRequest] testExecuteCallbackOnlyOnce");
    __block NSInteger callCount = 0;
    GGTestRequest *req = [[GGTestRequest alloc] init];

    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        callCount++;
        NSLog(@"   第 %ld 次回调", (long)callCount);
    }];

    NSLog(@"   调用 1：executeCallback:YES");
    [req executeCallback:YES statusCode:@(1)];
    NSLog(@"   调用 2：executeCallback:YES");
    [req executeCallback:YES statusCode:@(1)];
    NSLog(@"   调用 3：executeCallback:NO");
    [req executeCallback:NO statusCode:@(2)];

    NSLog(@"   最终 callCount = %ld", (long)callCount);
    XCTAssertEqual(callCount, 1, @"回调只应执行一次");
    NSLog(@"✅ [BaseRequest] 防重复回调验证通过");
}

#pragma mark - cancel

- (void)testCancelPreventsCallback {
    NSLog(@"▶️ [BaseRequest] testCancelPreventsCallback");
    __block BOOL called = NO;
    GGTestRequest *req = [[GGTestRequest alloc] init];

    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        called = YES;
        NSLog(@"   ⚠️ 取消后回调不应执行，但被触发了");
    }];

    NSLog(@"   调用 cancel");
    [req cancel];
    NSLog(@"   cancel 后 cancelled = %@, onCancelCalled = %@",
          req.cancelled ? @"YES" : @"NO",
          req.onCancelCalled ? @"YES" : @"NO");

    NSLog(@"   尝试 executeCallback");
    [req executeCallback:YES statusCode:@(1)];

    NSLog(@"   最终 called = %@", called ? @"YES" : @"NO");
    XCTAssertFalse(called, @"取消后回调不应执行");
    XCTAssertTrue(req.cancelled);
    XCTAssertTrue(req.onCancelCalled);
    NSLog(@"✅ [BaseRequest] cancel 阻止回调验证通过");
}

- (void)testCancelIsIdempotent {
    NSLog(@"▶️ [BaseRequest] testCancelIsIdempotent");
    GGTestRequest *req = [[GGTestRequest alloc] init];
    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {}];

    NSLog(@"   连续调用 cancel 三次");
    [req cancel];
    [req cancel];
    [req cancel];

    NSLog(@"   onCancelCallCount = %ld", (long)req.onCancelCallCount);
    XCTAssertTrue(req.cancelled);
    XCTAssertEqual(req.onCancelCallCount, 1, @"onCancel 只应执行一次");
    NSLog(@"✅ [BaseRequest] cancel 幂等性验证通过");
}

#pragma mark - 超时

- (void)testTimeoutTriggersCallback {
    NSLog(@"▶️ [BaseRequest] testTimeoutTriggersCallback");
    XCTestExpectation *exp = [self expectationWithDescription:@"超时"];

    // 自定义超时时间短的子类
    GGTestRequest *req = [[GGTestRequest alloc] init];
    [req startRequest:GGPermissionTypeCamera callback:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   ⏰ 超时回调：granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        [exp fulfill];
    }];

    [req startTimeoutIfNeeded];

    // 默认 15s 超时，测试等待 16s
    NSLog(@"   等待 16s 触发超时...");
    [self waitForExpectationsWithTimeout:17 handler:nil];
    NSLog(@"✅ [BaseRequest] 超时回调验证通过");
}

@end
