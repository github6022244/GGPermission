//
//  GGPermissionMicrophoneHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionMicrophoneHandler.h"
#import "GGPermissionMicrophoneRequest.h"
#import "GGPermission.h"
#import <AVFoundation/AVFoundation.h>

@implementation GGPermissionMicrophoneHandler

#pragma mark - 基类 hook

- (GGPermissionBaseRequest *)createRequest {
    return [[GGPermissionMicrophoneRequest alloc] init];
}

/// 同步读取麦克风授权状态
- (nullable NSNumber *)currentSystemStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    return @(status);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    return (AVAuthorizationStatus)s == AVAuthorizationStatusAuthorized;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    AVAuthorizationStatus status = (AVAuthorizationStatus)s;
    return status == AVAuthorizationStatusDenied ||
           status == AVAuthorizationStatusRestricted;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    return [GGPermission shareInstance].microphonePushSettingTips;
}

@end
