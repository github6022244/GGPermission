//
//  GGPermissionCameraRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionCameraRequest.h"
#import "GGPermissionDefine.h"
#import <AVFoundation/AVFoundation.h>

@implementation GGPermissionCameraRequest

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    // 1. 重置状态 + 保存回调
    [self prepareForNewRequest];
    self.callback = callback;

    // 2. 启动超时兜底
    [self startTimeoutIfNeeded];

    // 3. 发起系统请求
    __weak typeof(self) ws = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                            completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            [strongSelf executeCallback:granted statusCode:@(status)];
        });
    }];
}

#pragma mark - 基类 hook

/// 超时兜底：相机状态可同步读取
- (nullable NSNumber *)currentSystemStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) return nil;
    return @(status);
}

/// 取消时无需清理平台资源
- (void)onCancel {
    // no-op
}

@end
