//
//  GGPermissionPhotoRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionPhotoRequest.h"
#import "GGPermissionDefine.h"
#import <Photos/Photos.h>

@implementation GGPermissionPhotoRequest

- (instancetype)init {
    if (self = [super init]) {
        _accessType = GGPermissionTypePhoto;   // 默认读写
    }
    return self;
}

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    [self prepareForNewRequest];
    self.callback = callback;

    [self startTimeoutIfNeeded];

    if (@available(iOS 14, *)) {
        PHAccessLevel level = [self phAccessLevel];
        __weak typeof(self) ws = self;
        [PHPhotoLibrary requestAuthorizationForAccessLevel:level
                                                   handler:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) strongSelf = ws;
                if (!strongSelf) return;
                BOOL granted = [strongSelf isGrantedForStatus:status];
                [strongSelf executeCallback:granted statusCode:@(status)];
            });
        }];
    } else {
        // iOS 14 以下：只支持全局读写权限 API
        __weak typeof(self) ws = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(ws) strongSelf = ws;
                if (!strongSelf) return;
                BOOL granted = [strongSelf isGrantedForStatus:status];
                [strongSelf executeCallback:granted statusCode:@(status)];
            });
        }];
    }
}

#pragma mark - 基类 hook
- (nullable NSNumber *)currentSystemStatus {
    if (@available(iOS 14, *)) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:[self phAccessLevel]];
        if (status == PHAuthorizationStatusNotDetermined) return nil;
        return @(status);
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) return nil;
    return @(status);
}

- (void)onCancel {
    // no-op
}

#pragma mark - 辅助
- (PHAccessLevel)phAccessLevel API_AVAILABLE(ios(14)) {
    return (self.accessType == GGPermissionTypePhotoAddOnly)
        ? PHAccessLevelAddOnly
        : PHAccessLevelReadWrite;
}

- (BOOL)isGrantedForStatus:(PHAuthorizationStatus)status {
    if (self.accessType == GGPermissionTypePhotoAddOnly) {
        // 只写：只有 Authorized 算授权
        return status == PHAuthorizationStatusAuthorized;
    }
    // 读写
    if (@available(iOS 14, *)) {
        return status == PHAuthorizationStatusAuthorized ||
               status == PHAuthorizationStatusLimited;
    }
    return status == PHAuthorizationStatusAuthorized;
}

@end
