//
//  GGPermissionNotificationRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionNotificationRequest.h"
#import "GGPermissionDefine.h"
#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@implementation GGPermissionNotificationRequest

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    [self prepareForNewRequest];
    self.callback = callback;

    [self startTimeoutIfNeeded];

    // 请求通知权限
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = (UNAuthorizationOptionAlert |
                                      UNAuthorizationOptionSound |
                                      UNAuthorizationOptionBadge);

    __weak typeof(self) ws = self;
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            // 若授权成功，注册 APNs
            if (granted) {
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }

            // 回调时读一次真实状态（更准确）
            [strongSelf fetchCurrentStatusWithGranted:granted];
        });
    }];
}

#pragma mark - 读取真实状态后回调
- (void)fetchCurrentStatusWithGranted:(BOOL)granted {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    __weak typeof(self) ws = self;
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            UNAuthorizationStatus status = settings.authorizationStatus;
            BOOL realGranted = NO;
            if (@available(iOS 14.0, *)) {
                realGranted = (status == UNAuthorizationStatusAuthorized ||
                                    status == UNAuthorizationStatusProvisional ||
                                    status == UNAuthorizationStatusEphemeral);
            } else {
                realGranted = (status == UNAuthorizationStatusAuthorized ||
                               status == UNAuthorizationStatusProvisional);
            }
            
            [strongSelf executeCallback:realGranted statusCode:@(status)];
        });
    }];
}

#pragma mark - 基类 hook
/// 超时兜底：同步读不到通知状态，返回 nil → 走 Timeout 错误码
- (nullable NSNumber *)currentSystemStatus {
    return nil;
}

/// 取消时无需清理平台资源
- (void)onCancel {
    // no-op
}

@end
