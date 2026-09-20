//
//  GGPermissionCameraHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionCameraHandler.h"
#import "GGPermissionCameraRequest.h"
#import "GGPermission.h"
#import <AVFoundation/AVFoundation.h>

@implementation GGPermissionCameraHandler

- (GGPermissionBaseRequest *)createRequest {
    return [[GGPermissionCameraRequest alloc] init];
}

- (nullable NSNumber *)currentSystemStatus {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
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
    return [GGPermission shareInstance].cameraPushSettingTips;
}

@end
