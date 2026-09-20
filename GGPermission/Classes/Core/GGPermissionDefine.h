//
//  GGPermissionDefine.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 权限类型
typedef NS_ENUM(NSInteger, GGPermissionType) {
    GGPermissionTypePhoto = 0,          // 相册 - 读写
    GGPermissionTypePhotoAddOnly,       // 相册 - 只写
    GGPermissionTypeCamera,
    GGPermissionTypeLocationWhen,
    GGPermissionTypeLocationAlways,
    GGPermissionTypeMicrophone,
    GGPermissionTypeContacts,
    GGPermissionTypeNotification,
    GGPermissionTypeCalendarFullAccess, // 日历 - 完整访问
    GGPermissionTypeCalendarWriteOnly,  // 日历 - 只写访问
    GGPermissionTypeBluetooth,
    GGPermissionTypeHealth,           // 健康综合（一次请求多种常用类型）
    GGPermissionTypeHealthSteps,      // 步数（读）
    GGPermissionTypeHealthHeartRate,  // 心率（读）
    GGPermissionTypeHealthSleep,      // 睡眠（读）
    GGPermissionTypeHealthWorkout,    // 锻炼（读）
};

/// 工具类内部错误码（负数为内部错误，非负数为系统框架原始状态）
typedef NS_ENUM(NSInteger, GGPermissionError) {
    GGPermissionErrorUnknown = -1,
    GGPermissionErrorServiceDisabled = -2,
    GGPermissionErrorTimeout = -3,
    GGPermissionErrorNoTopViewController = -4,
};

/// 统一回调：granted 是否授权成功；statusCode 为系统原始状态或 GGPermissionError
typedef void(^GGPermissionCallback)(BOOL granted, NSNumber *statusCode);
