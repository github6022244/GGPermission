//
//  GGPermissionCalendarHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionCalendarHandler.h"
#import "GGPermissionCalendarRequest.h"
#import "GGPermission.h"
#import <EventKit/EventKit.h>

@interface GGPermissionCalendarHandler ()
@property (nonatomic, assign) GGPermissionType currentCalendarType;
@end

@implementation GGPermissionCalendarHandler

- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    self.currentCalendarType = type;
    [super requestPermission:type callback:callback];
}

- (GGPermissionBaseRequest *)createRequest {
    GGPermissionCalendarRequest *req = [[GGPermissionCalendarRequest alloc] init];
    req.calendarType = self.currentCalendarType;
    return req;
}

- (nullable NSNumber *)currentSystemStatus {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    return @(status);
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    EKAuthorizationStatus status = (EKAuthorizationStatus)s;

    // FullAccess 和 Authorized 同值（3），统一用 FullAccess 判断
    BOOL hasFullAccess = NO;
    if (@available(iOS 17.0, *)) {
        hasFullAccess = (status == EKAuthorizationStatusFullAccess);
    } else {
        hasFullAccess = (status == EKAuthorizationStatusAuthorized);
    }
    
    // WriteOnly 只在 iOS 17+ 存在，需要版本判断
    BOOL hasWriteOnly = NO;
    if (@available(iOS 17.0, *)) {
        hasWriteOnly = (status == EKAuthorizationStatusWriteOnly);
    }

    if (self.currentCalendarType == GGPermissionTypeCalendarWriteOnly) {
        // 只写：WriteOnly 或 FullAccess（FullAccess 包含写能力）都算已授权
        return hasWriteOnly || hasFullAccess;
    } else {
        // 完整访问：只有 FullAccess 算
        return hasFullAccess;
    }
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    NSInteger s = statusCode.integerValue;
    if (s < 0) return NO;
    EKAuthorizationStatus status = (EKAuthorizationStatus)s;

    // Denied / Restricted 是通用状态
    if (status == EKAuthorizationStatusDenied ||
        status == EKAuthorizationStatusRestricted) {
        return YES;
    }

    // 特殊处理：FullAccess 请求下，WriteOnly 需要引导用户升级
    if (self.currentCalendarType == GGPermissionTypeCalendarFullAccess) {
        if (@available(iOS 17.0, *)) {
            if (status == EKAuthorizationStatusWriteOnly) {
                return YES;
            }
        }
    }

    return NO;
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    GGPermission *main = [GGPermission shareInstance];
    if (type == GGPermissionTypeCalendarWriteOnly) {
        return main.calendarWriteOnlyPushSettingTips ?: main.calendarPushSettingTips;
    }
    return main.calendarPushSettingTips;
}

@end
