//
//  GGPermissionHealthRequest.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionHealthRequest.h"
#import "GGPermissionDefine.h"
#import <HealthKit/HealthKit.h>

@implementation GGPermissionHealthRequest

- (instancetype)init {
    if (self = [super init]) {
        _healthType = GGPermissionTypeHealth;
    }
    return self;
}

#pragma mark - 发起请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback {
    [self prepareForNewRequest];
    self.callback = callback;
    self.healthType = type;
    [self startTimeoutIfNeeded];

    // 1. 设备是否支持 HealthKit
    if (![HKHealthStore isHealthDataAvailable]) {
        [self executeCallback:NO statusCode:@(GGPermissionErrorServiceDisabled)];
        return;
    }

    // 2. 根据 healthType 组装需要请求的 HKObjectType 集合
    NSSet<HKObjectType *> *readTypes = [self readTypesForHealthType:type];

    // 3. 发起请求
    HKHealthStore *store = [[HKHealthStore alloc] init];
    __weak typeof(self) ws = self;
    [store requestAuthorizationToShareTypes:nil
                                  readTypes:readTypes
                                 completion:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(ws) strongSelf = ws;
            if (!strongSelf) return;

            // HealthKit 回调只告诉你"弹窗流程是否完成"，
            // 用户是否同意需通过读数据时判断。
            // 此处约定：success = YES 即认为用户完成了授权选择。
            [strongSelf executeCallback:success
                             statusCode:@(success ? 0 : GGPermissionErrorUnknown)];
        });
    }];
}

#pragma mark - 类型映射
- (NSSet<HKObjectType *> *)readTypesForHealthType:(GGPermissionType)type {
    NSMutableSet<HKObjectType *> *set = [NSMutableSet set];

    void (^addType)(HKQuantityTypeIdentifier) = ^(HKQuantityTypeIdentifier identifier) {
        HKQuantityType *t = [HKObjectType quantityTypeForIdentifier:identifier];
        if (t) [set addObject:t];
    };

    switch (type) {
        case GGPermissionTypeHealthSteps:
            addType(HKQuantityTypeIdentifierStepCount);
            break;

        case GGPermissionTypeHealthHeartRate:
            addType(HKQuantityTypeIdentifierHeartRate);
            break;

        case GGPermissionTypeHealthSleep:
            if (@available(iOS 16.0, *)) {
                HKCategoryType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
                if (sleepType) [set addObject:sleepType];
            } else {
                HKCategoryType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
                if (sleepType) [set addObject:sleepType];
            }
            break;

        case GGPermissionTypeHealthWorkout:
            if (@available(iOS 17.0, *)) {
                HKObjectType *workoutType = [HKObjectType workoutType];
                if (workoutType) [set addObject:workoutType];
            } else {
                HKObjectType *workoutType = [HKObjectType workoutType];
                if (workoutType) [set addObject:workoutType];
            }
            break;

        case GGPermissionTypeHealth:
        default:
            // 综合：请求常用类型
            addType(HKQuantityTypeIdentifierStepCount);
            addType(HKQuantityTypeIdentifierHeartRate);
            {
                HKCategoryType *sleepType = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
                if (sleepType) [set addObject:sleepType];
            }
            {
                HKObjectType *workoutType = [HKObjectType workoutType];
                if (workoutType) [set addObject:workoutType];
            }
            break;
    }

    return [set copy];
}

#pragma mark - 基类 hook
- (nullable NSNumber *)currentSystemStatus {
    // HealthKit 无法同步查询授权状态
    return nil;
}

- (void)onCancel {
    // no-op
}

@end
