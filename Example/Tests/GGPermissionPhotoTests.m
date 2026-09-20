//
//  GGPermissionPhotoTests.m
//  GGPermission_Tests
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GGPermissionPhotoHandler.h"
#import "GGPermissionDefine.h"
#import <Photos/Photos.h>

@interface GGPermissionPhotoHandler (Test)
@property (nonatomic, assign) GGPermissionType currentPhotoType;
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;
@end

@interface GGPermissionPhotoTests : XCTestCase
@property (nonatomic, strong) GGPermissionPhotoHandler *handler;
@end

@implementation GGPermissionPhotoTests

- (void)setUp {
    self.handler = [[GGPermissionPhotoHandler alloc] init];
    NSLog(@"   [Photo] handler 初始化完成");
}

#pragma mark - 读写

- (void)testReadWriteGrantedForAuthorized {
    NSLog(@"▶️ [Photo] testReadWriteGrantedForAuthorized");
    self.handler.currentPhotoType = GGPermissionTypePhoto;
    NSNumber *code = @(PHAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   type = Photo(读写), status = %@ (Authorized), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Photo] 读写 + Authorized 判为已授权");
}

- (void)testReadWriteGrantedForLimited {
    NSLog(@"▶️ [Photo] testReadWriteGrantedForLimited");
    self.handler.currentPhotoType = GGPermissionTypePhoto;
    NSNumber *code = @(PHAuthorizationStatusLimited);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   type = Photo(读写), status = %@ (Limited), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Photo] 读写 + Limited 判为已授权");
}

- (void)testReadWriteNotGrantedForDenied {
    NSLog(@"▶️ [Photo] testReadWriteNotGrantedForDenied");
    self.handler.currentPhotoType = GGPermissionTypePhoto;
    NSNumber *code = @(PHAuthorizationStatusDenied);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   type = Photo(读写), status = %@ (Denied), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted);
    NSLog(@"✅ [Photo] 读写 + Denied 判为未授权");
}

#pragma mark - 只写

- (void)testAddOnlyGrantedForAuthorized {
    NSLog(@"▶️ [Photo] testAddOnlyGrantedForAuthorized");
    self.handler.currentPhotoType = GGPermissionTypePhotoAddOnly;
    NSNumber *code = @(PHAuthorizationStatusAuthorized);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   type = PhotoAddOnly(只写), status = %@ (Authorized), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertTrue(granted);
    NSLog(@"✅ [Photo] 只写 + Authorized 判为已授权");
}

- (void)testAddOnlyNotGrantedForLimited {
    NSLog(@"▶️ [Photo] testAddOnlyNotGrantedForLimited");
    self.handler.currentPhotoType = GGPermissionTypePhotoAddOnly;
    NSNumber *code = @(PHAuthorizationStatusLimited);
    BOOL granted = [self.handler isGrantedForStatus:code];
    NSLog(@"   type = PhotoAddOnly(只写), status = %@ (Limited), granted = %@", code, granted ? @"YES" : @"NO");
    XCTAssertFalse(granted, @"只写场景不应接受 Limited 状态");
    NSLog(@"✅ [Photo] 只写 + Limited 判为未授权（符合预期）");
}

#pragma mark - Denied / Restricted

- (void)testDeniedOrRestricted {
    NSLog(@"▶️ [Photo] testDeniedOrRestricted");
    self.handler.currentPhotoType = GGPermissionTypePhoto;

    NSNumber *denied = @(PHAuthorizationStatusDenied);
    NSNumber *restricted = @(PHAuthorizationStatusRestricted);
    NSNumber *authorized = @(PHAuthorizationStatusAuthorized);

    BOOL d = [self.handler isDeniedOrRestrictedForStatus:denied];
    BOOL r = [self.handler isDeniedOrRestrictedForStatus:restricted];
    BOOL a = [self.handler isDeniedOrRestrictedForStatus:authorized];

    NSLog(@"   Denied → isDeniedOrRestricted = %@", d ? @"YES" : @"NO");
    NSLog(@"   Restricted → isDeniedOrRestricted = %@", r ? @"YES" : @"NO");
    NSLog(@"   Authorized → isDeniedOrRestricted = %@", a ? @"YES" : @"NO");

    XCTAssertTrue(d);
    XCTAssertTrue(r);
    XCTAssertFalse(a);
    NSLog(@"✅ [Photo] Denied/Restricted 判断验证通过");
}

@end
