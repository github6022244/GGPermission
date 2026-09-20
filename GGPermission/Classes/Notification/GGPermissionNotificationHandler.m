//
//  GGPermissionNotificationHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionNotificationHandler.h"
#import "GGPermissionNotificationRequest.h"
#import "GGPermission.h"
#import <UserNotifications/UserNotifications.h>

@implementation GGPermissionNotificationHandler

#pragma mark - 主入口（通知读取状态是异步的，需重写）
- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __weak typeof(self) ws = self;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            UNAuthorizationStatus status = settings.authorizationStatus;
            NSNumber *statusCode = @(status);

            // 1. 已授权（含 Provisional / Ephemeral）
            if ([strongSelf isGrantedForStatus:statusCode]) {
                if (callback) callback(YES, statusCode);
                return;
            }

            // 2. 已拒绝 / 受限 → 引导设置
            if ([strongSelf isDeniedOrRestrictedForStatus:statusCode]) {
                [strongSelf guideToSettingWithType:type status:statusCode callback:callback];
                return;
            }

            // 3. NotDetermined → 发起请求
            [strongSelf startRequestWithType:type callback:callback];
        });
    }];
}

#pragma mark - 基类 hook
- (GGPermissionBaseRequest *)createRequest {
    return [[GGPermissionNotificationRequest alloc] init];
}

/// 通知的"当前状态"读取是异步的，这里返回 nil；
/// 主入口已重写，不走基类同步流程
- (nullable NSNumber *)currentSystemStatus {
    return nil;
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    UNAuthorizationStatus status = (UNAuthorizationStatus)s;
    
    BOOL granted = NO;
    if (@available(iOS 14.0, *)) {
        granted = status == UNAuthorizationStatusAuthorized ||
        status == UNAuthorizationStatusProvisional ||
        status == UNAuthorizationStatusEphemeral;
    } else {
        granted = status == UNAuthorizationStatusAuthorized ||
        status == UNAuthorizationStatusProvisional;
    }
    
    return granted;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    UNAuthorizationStatus status = (UNAuthorizationStatus)s;
    return status == UNAuthorizationStatusDenied;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return [GGPermission shareInstance].notificationPushSettingTips;
}

@end
