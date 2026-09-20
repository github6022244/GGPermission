//
//  GGPermissionMicrophoneTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionMicrophoneHandler.h"
#import "GGPermissionBaseHandler.h"
#import "GGPermissionBaseRequest.h"
#import "GGPermissionDefine.h"
#import <GGPermission.h>
#import <AVFoundation/AVFoundation.h>

#pragma mark - 暴露私有 hook 方法（测试用）

@interface GGPermissionMicrophoneHandler (Test)
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
- (nullable NSNumber *)currentSystemStatus;
- (GGPermissionBaseRequest *)createRequest;
- (NSString *)guideTipsForType:(GGPermissionType)type;
@end

#pragma mark - 测试类

@interface GGPermissionMicrophoneTests : XCTestCase
@property (nonatomic, strong) GGPermissionMicrophoneHandler *handler;
@end

@implementation GGPermissionMicrophoneTests

- (void)setUp {
    [super setUp];
    self.handler = [[GGPermissionMicrophoneHandler alloc] init];
    NSLog(@"   [Microphone] handler 初始化完成: %@", self.handler);
}

- (void)tearDown {
    self.handler = nil;
    NSLog(@"   [Microphone] handler 已释放");
    [super tearDown];
}

#pragma mark - isGrantedForStatus:

- (void)testGrantedForAuthorized {
    NSLog(@"▶️ [Microphone] testGrantedForAuthorized");
    NSNumber *code = @(AVAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Authorized), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Microphone] Authorized 判为已授权");
}

- (void)testNotGrantedForDenied {
    NSLog(@"▶️ [Microphone] testNotGrantedForDenied");
    NSNumber *code = @(AVAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Microphone] Denied 判为未授权");
}

- (void)testNotGrantedForRestricted {
    NSLog(@"▶️ [Microphone] testNotGrantedForRestricted");
    NSNumber *code = @(AVAuthorizationStatusRestricted);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (Restricted), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Microphone] Restricted 判为未授权");
}

- (void)testNotGrantedForNotDetermined {
    NSLog(@"▶️ [Microphone] testNotGrantedForNotDetermined");
    NSNumber *code = @(AVAuthorizationStatusNotDetermined);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Microphone] NotDetermined 判为未授权");
}

- (void)testNotGrantedForNegativeCode {
    NSLog(@"▶️ [Microphone] testNotGrantedForNegativeCode");
    NSNumber *code = @(GGPermissionErrorServiceDisabled);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   status = %@ (ServiceDisabled), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Microphone] 负错误码判为未授权");
}

#pragma mark - isDeniedOrRestrictedForStatus:

- (void)testDeniedOrRestrictedForDenied {
    NSLog(@"▶️ [Microphone] testDeniedOrRestrictedForDenied");
    NSNumber *code = @(AVAuthorizationStatusDenied);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Denied), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertTrue(result);
    NSLog(@"✅ [Microphone] Denied 判为已拒绝/受限");
}

- (void)testDeniedOrRestrictedForRestricted {
    NSLog(@"▶️ [Microphone] testDeniedOrRestrictedForRestricted");
    NSNumber *code = @(AVAuthorizationStatusRestricted);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Restricted), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertTrue(result);
    NSLog(@"✅ [Microphone] Restricted 判为已拒绝/受限");
}

- (void)testNotDeniedForAuthorized {
    NSLog(@"▶️ [Microphone] testNotDeniedForAuthorized");
    NSNumber *code = @(AVAuthorizationStatusAuthorized);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (Authorized), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result);
    NSLog(@"✅ [Microphone] Authorized 不算已拒绝/受限");
}

- (void)testNotDeniedForNotDetermined {
    NSLog(@"▶️ [Microphone] testNotDeniedForNotDetermined");
    NSNumber *code = @(AVAuthorizationStatusNotDetermined);
    BOOL result = [self.handler isDeniedOrRestrictedForStatus:code];
    NSLog(@"   status = %@ (NotDetermined), isDeniedOrRestricted = %@", code, result ? @"YES" : @"NO");
    XCTAssertFalse(result);
    NSLog(@"✅ [Microphone] NotDetermined 不算已拒绝/受限");
}

#pragma mark - currentSystemStatus

- (void)testCurrentSystemStatusReturnsValidValue {
    NSLog(@"▶️ [Microphone] testCurrentSystemStatusReturnsValidValue");
    NSNumber *status = [self.handler currentSystemStatus];
    NSLog(@"   currentSystemStatus = %@", status);
    XCTAssertNotNil(status);
    NSLog(@"✅ [Microphone] currentSystemStatus 返回有效值");
}

- (void)testCurrentSystemStatusMatchesSystem {
    NSLog(@"▶️ [Microphone] testCurrentSystemStatusMatchesSystem");
    NSNumber *handlerStatus = [self.handler currentSystemStatus];
    AVAuthorizationStatus systemStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    NSLog(@"   handler = %@, system = %ld", handlerStatus, (long)systemStatus);
    XCTAssertEqual(handlerStatus.integerValue, (NSInteger)systemStatus);
    NSLog(@"✅ [Microphone] 与系统状态一致");
}

#pragma mark - guideTips / createRequest

- (void)testGuideTipsForMicrophone {
    NSLog(@"▶️ [Microphone] testGuideTipsForMicrophone");
    NSString *tips = [self.handler guideTipsForType:GGPermissionTypeMicrophone];
    NSLog(@"   guideTips = \"%@\"", tips);
    XCTAssertTrue(tips.length > 0);
    NSLog(@"✅ [Microphone] 引导文案非空");
}

- (void)testCreateRequestReturnsValidRequest {
    NSLog(@"▶️ [Microphone] testCreateRequestReturnsValidRequest");
    GGPermissionBaseRequest *req = [self.handler createRequest];
    NSLog(@"   createRequest = %@", req);
    XCTAssertNotNil(req);
    NSLog(@"✅ [Microphone] createRequest 返回有效 Request");
}

#pragma mark - 端到端

- (void)testRequestPermissionEndToEnd {
    NSLog(@"▶️ [Microphone] testRequestPermissionEndToEnd");
    XCTestExpectation *exp = [self expectationWithDescription:@"麦克风权限请求"];

    [[GGPermission shareInstance] permissonType:GGPermissionTypeMicrophone
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        NSLog(@"   回调 granted = %@, statusCode = %@", granted ? @"YES" : @"NO", statusCode);
        XCTAssertNotNil(statusCode);
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:30 handler:nil];
    NSLog(@"✅ [Microphone] 端到端请求完成");
}

@end
