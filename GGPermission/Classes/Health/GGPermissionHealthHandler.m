//
//  GGPermissionHealthHandler.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionHealthHandler.h"
#import "GGPermissionHealthRequest.h"
#import "GGPermission.h"
#import <HealthKit/HealthKit.h>

@interface GGPermissionHealthHandler ()
@property (nonatomic, assign) GGPermissionType currentHealthType;
@end

@implementation GGPermissionHealthHandler

#pragma mark - 重写：HealthKit 无法同步判断状态，直接走 Request
- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    self.currentHealthType = type;
    // 不走基类同步模板，直接发起请求
    [self startRequestWithType:type callback:callback];
}

#pragma mark - 基类 hook
- (GGPermissionBaseRequest *)createRequest {
    GGPermissionHealthRequest *req = [[GGPermissionHealthRequest alloc] init];
    req.healthType = self.currentHealthType;
    return req;
}

/// HealthKit 无法同步查询，返回 nil（不会走到同步模板）
- (nullable NSNumber *)currentSystemStatus {
    return nil;
}

- (BOOL)isGrantedForStatus:(NSNumber *)statusCode {
    return statusCode.integerValue >= 0;
}

- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode {
    return NO;   // HealthKit 拒绝后也直接发起请求（系统会弹窗或直接返回）
}

- (NSString *)guideTipsForType:(GGPermissionType)type {
    GGPermission *main = [GGPermission shareInstance];
    switch (type) {
        case GGPermissionTypeHealthSteps:
            return main.healthStepsPushSettingTips ?: main.healthPushSettingTips;
        case GGPermissionTypeHealthHeartRate:
            return main.healthHeartRatePushSettingTips ?: main.healthPushSettingTips;
        case GGPermissionTypeHealthSleep:
            return main.healthSleepPushSettingTips ?: main.healthPushSettingTips;
        case GGPermissionTypeHealthWorkout:
            return main.healthWorkoutPushSettingTips ?: main.healthPushSettingTips;
        case GGPermissionTypeHealth:
        default:
            return main.healthPushSettingTips;
    }
}

@end
