//
//  GGPermissionPhotoHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionPhotoHandler.h"
#import "GGPermissionPhotoRequest.h"
#import "GGPermission.h"
#import <Photos/Photos.h>

@interface GGPermissionPhotoHandler ()
/// 当前请求的权限类型（读写 / 只写），由 requestPermission: 设置
@property (nonatomic, assign) GGPermissionType currentPhotoType;
@end

@implementation GGPermissionPhotoHandler

#pragma mark - 主入口
- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    self.currentPhotoType = type;   // 记录本次请求的级别

    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber *status = [self currentSystemStatus];

        if ([self isGrantedForStatus:status]) {
            if (callback) callback(YES, status);
            return;
        }
        if ([self isDeniedOrRestrictedForStatus:status]) {
            [self guideToSettingWithType:type status:status callback:callback];
            return;
        }
        // NotDetermined → 发起请求
        [self startRequestWithType:type callback:callback];
    });
}

#pragma mark - 基类 hook
- (GGPermissionBaseRequest *)createRequest {
    GGPermissionPhotoRequest *req = [[GGPermissionPhotoRequest alloc] init];
    req.accessType = self.currentPhotoType;
    return req;
}

/// 按当前 type 读取状态
- (nullable NSNumber *)currentSystemStatus {
    GGPermissionType type = self.currentPhotoType ?: GGPermissionTypePhoto;

    if (@available(iOS 14, *)) {
        PHAccessLevel level = (type == GGPermissionTypePhotoAddOnly)
            ? PHAccessLevelAddOnly
            : PHAccessLevelReadWrite;
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        return @(status);
    }
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return @(status);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    PHAuthorizationStatus status = (PHAuthorizationStatus)s;

    GGPermissionType type = self.currentPhotoType ?: GGPermissionTypePhoto;
    if (type == GGPermissionTypePhotoAddOnly) {
        return status == PHAuthorizationStatusAuthorized;
    }
    if (@available(iOS 14, *)) {
        return status == PHAuthorizationStatusAuthorized ||
               status == PHAuthorizationStatusLimited;
    }
    return status == PHAuthorizationStatusAuthorized;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    PHAuthorizationStatus status = (PHAuthorizationStatus)s;
    return status == PHAuthorizationStatusDenied ||
           status == PHAuthorizationStatusRestricted;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    GGPermission *main = [GGPermission shareInstance];
    if (type == GGPermissionTypePhotoAddOnly) {
        return main.photoAddOnlyPushSettingTips ?: main.photoPushSettingTips;
    }
    return main.photoPushSettingTips;
}

@end
