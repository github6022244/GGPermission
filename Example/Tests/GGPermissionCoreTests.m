//
//  GGPermissionCoreTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GGPermission/GGPermission.h>

@interface GGPermissionCoreTests : XCTestCase
@end

@implementation GGPermissionCoreTests

#pragma mark - 生命周期

- (void)setUp {
    [super setUp];
    // 每个测试方法执行前重置单例状态（如果库支持）
    // 如果 GGPermission 不支持 reset，注释掉下面这行
    // [GGPermission resetInstance];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - 单例

- (void)testShareInstanceIsSingleton {
    NSLog(@"▶️ [Core] testShareInstanceIsSingleton");
    GGPermission *a = [GGPermission shareInstance];
    GGPermission *b = [GGPermission shareInstance];
    NSLog(@"   a = %p, b = %p", a, b);
    XCTAssertEqual(a, b, @"单例应返回同一实例");
    NSLog(@"✅ [Core] 单例验证通过");
}

- (void)testAllocReturnsSameInstance {
    NSLog(@"▶️ [Core] testAllocReturnsSameInstance");
    GGPermission *a = [GGPermission shareInstance];
    GGPermission *b = [[GGPermission alloc] init];
    NSLog(@"   shareInstance = %p, alloc init = %p", a, b);
    XCTAssertEqual(a, b, @"alloc 应返回单例");
    NSLog(@"✅ [Core] alloc 验证通过");
}

- (void)testNewReturnsSameInstance {
    NSLog(@"▶️ [Core] testNewReturnsSameInstance");
    GGPermission *a = [GGPermission shareInstance];
    GGPermission *b = [GGPermission new];
    NSLog(@"   shareInstance = %p, new = %p", a, b);
    XCTAssertEqual(a, b, @"new 应返回单例");
    NSLog(@"✅ [Core] new 验证通过");
}

- (void)testCopyReturnsSameInstance {
    NSLog(@"▶️ [Core] testCopyReturnsSameInstance");
    GGPermission *a = [GGPermission shareInstance];
    GGPermission *b = [a copy];
    NSLog(@"   original = %p, copy = %p", a, b);
    XCTAssertEqual(a, b, @"copy 应返回单例");
    NSLog(@"✅ [Core] copy 验证通过");
}

- (void)testMutableCopyReturnsSameInstance {
    NSLog(@"▶️ [Core] testMutableCopyReturnsSameInstance");
    GGPermission *a = [GGPermission shareInstance];
    GGPermission *b = [a mutableCopy];
    NSLog(@"   original = %p, mutableCopy = %p", a, b);
    XCTAssertEqual(a, b, @"mutableCopy 应返回单例");
    NSLog(@"✅ [Core] mutableCopy 验证通过");
}

#pragma mark - 线程安全

- (void)testConcurrentCreateIsThreadSafe {
    NSLog(@"▶️ [Core] testConcurrentCreateIsThreadSafe");

    // 用 __autoreleasing 修饰双星指针，兼容 ARC
    GGPermission * __autoreleasing *instances = (GGPermission * __autoreleasing *)malloc(sizeof(GGPermission *) * 100);
    dispatch_group_t group = dispatch_group_create();

    for (int i = 0; i < 100; i++) {
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            instances[i] = [GGPermission shareInstance];
            dispatch_group_leave(group);
        });
    }

    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

    GGPermission *first = instances[0];
    for (int i = 1; i < 100; i++) {
        XCTAssertEqual(instances[i], first, @"多线程并发创建应返回同一实例 (index=%d)", i);
    }

    free(instances);
    NSLog(@"✅ [Core] 线程安全验证通过（100 线程并发）");
}

#pragma mark - 默认配置

- (void)testDefaultAutoTipEnable {
    NSLog(@"▶️ [Core] testDefaultAutoTipEnable");
    BOOL enabled = [GGPermission shareInstance].autoTipEnable;
    NSLog(@"   autoTipEnable = %@", enabled ? @"YES" : @"NO");
    XCTAssertTrue(enabled, @"默认应开启自动弹窗");
    NSLog(@"✅ [Core] autoTipEnable 默认值验证通过");
}

- (void)testDefaultPushSettingTips {
    NSLog(@"▶️ [Core] testDefaultPushSettingTips");
    GGPermission *p = [GGPermission shareInstance];

    // 用结构体数组替代字典，避免 key 拼写错误导致漏测
    struct { const char *name; NSString *value; } cases[] = {
        {"camera",            p.cameraPushSettingTips},
        {"photo",             p.photoPushSettingTips},
        {"photoAddOnly",      p.photoAddOnlyPushSettingTips},
        {"locationWhen",      p.locationWhenPushSettingTips},
        {"locationAlways",    p.locationAlwaysPushSettingTips},
        {"microphone",        p.microphonePushSettingTips},
        {"contacts",          p.contactsPushSettingTips},
        {"notification",      p.notificationPushSettingTips},
        {"calendar",          p.calendarPushSettingTips},
        {"calendarWriteOnly", p.calendarWriteOnlyPushSettingTips},
        {"bluetooth",         p.bluetoothPushSettingTips},
        {"health",            p.healthPushSettingTips},
        {"healthSteps",       p.healthStepsPushSettingTips},
        {"healthHeartRate",   p.healthHeartRatePushSettingTips},
        {"healthSleep",       p.healthSleepPushSettingTips},
        {"healthWorkout",     p.healthWorkoutPushSettingTips},
    };

    for (size_t i = 0; i < sizeof(cases)/sizeof(cases[0]); i++) {
        NSString *value = cases[i].value ?: @"";
        NSLog(@"   %s.tips = \"%@\"", cases[i].name, value);
        XCTAssertFalse(value.length == 0, @"%s 的默认文案不应为空", cases[i].name);
    }

    NSLog(@"✅ [Core] 所有默认文案非空验证通过");
}

#pragma mark - 未知 subspec

- (void)testUnknownSubspecReturnsError {
    NSLog(@"▶️ [Core] testUnknownSubspecReturnsError");
    XCTestExpectation *exp = [self expectationWithDescription:@"未知 subspec"];
    GGPermissionType unknownType = (GGPermissionType)9999;
    NSLog(@"   请求 type = %ld", (long)unknownType);

    [[GGPermission shareInstance] permissonType:unknownType
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   回调 granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        XCTAssertFalse(granted, @"未知 type 应返回未授权");
        XCTAssertEqual(statusCode.integerValue, GGPermissionErrorUnknown);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:^(NSError * _Nullable error) {
        if (error) {
            XCTFail(@"未知 subspec 回调超时，可能未正确处理");
        }
    }];
    NSLog(@"✅ [Core] 未知 subspec 返回 Unknown 验证通过");
}

#pragma mark - 连续请求（同 type 验证丢弃逻辑）

- (void)testConsecutiveRequestsDiscardsOldBlock {
    NSLog(@"▶️ [Core] testConsecutiveRequestsDiscardsOldBlock");
    GGPermission *p = [GGPermission shareInstance];
    __block BOOL firstCallbackCalled = NO;
    __block BOOL secondCallbackCalled = NO;

    // 第一次请求（Photo）
    NSLog(@"   发起第一次请求（Photo）");
    [p permissonType:GGPermissionTypePhoto withHandle:^(BOOL granted, NSNumber *statusCode) {
        firstCallbackCalled = YES;
        NSLog(@"   ⚠️ 第一次回调被触发（不应发生）granted = %@", granted ? @"YES" : @"NO");
    }];

    // 第二次请求（同样是 Photo，才能验证丢弃逻辑）
    NSLog(@"   发起第二次请求（Photo）");
    XCTestExpectation *exp = [self expectationWithDescription:@"第二次请求完成"];
    [p permissonType:GGPermissionTypePhoto withHandle:^(BOOL granted, NSNumber *statusCode) {
        secondCallbackCalled = YES;
        NSLog(@"   第二次回调 granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
    NSLog(@"   firstCallbackCalled = %@", firstCallbackCalled ? @"YES" : @"NO");
    NSLog(@"   secondCallbackCalled = %@", secondCallbackCalled ? @"YES" : @"NO");
    XCTAssertFalse(firstCallbackCalled, @"第一次请求的回调不应被触发");
    XCTAssertTrue(secondCallbackCalled, @"第二次请求的回调应被触发");
    NSLog(@"✅ [Core] 连续请求丢弃旧 block 验证通过");
}

#pragma mark - 未引入 subspec 请求

- (void)testUnimportedSubspecReturnsUnknown {
    NSLog(@"▶️ [Core] testUnimportedSubspecReturnsUnknown");
    GGPermission *permission = [GGPermission shareInstance];

    NSMutableDictionary *originMap = [permission valueForKey:@"handlerMap"];
    NSMutableDictionary *tempMap = [originMap mutableCopy];
    [tempMap removeObjectForKey:@(GGPermissionTypeLocationWhen)];
    [tempMap removeObjectForKey:@(GGPermissionTypeLocationAlways)];

    [permission setValue:tempMap forKey:@"handlerMap"];
    @try {
        __block NSNumber *resultStatusCode;
        [permission permissonType:GGPermissionTypeLocationWhen
                        withHandle:^(BOOL granted, NSNumber *statusCode) {
            NSLog(@"👉 回调执行 granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
            resultStatusCode = statusCode;
        }];
        XCTAssertEqual(resultStatusCode.integerValue, -1, @"未引入subspec，应当返回GGPermissionErrorUnknown(-1)");
    }
    @finally {
        // 无论测试成功/崩溃，一定会恢复原始handlerMap
        [permission setValue:originMap forKey:@"handlerMap"];
    }

    NSLog(@"✅ [Core] 未引入 subspec 行为验证完成");
}


#pragma mark - 回调线程验证

- (void)testCallbackExecutesOnMainThread {
    NSLog(@"▶️ [Core] testCallbackExecutesOnMainThread");
    XCTestExpectation *exp = [self expectationWithDescription:@"回调在主线程"];
    __block BOOL isMainThread = NO;

    [[GGPermission shareInstance] permissonType:GGPermissionTypePhoto
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        isMainThread = [NSThread isMainThread];
        NSLog(@"   回调线程: %@", isMainThread ? @"主线程 ✅" : @"子线程 ❌");
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:5 handler:nil];
    XCTAssertTrue(isMainThread, @"权限回调应在主线程执行");
    NSLog(@"✅ [Core] 回调主线程验证通过");
}

@end
