//
//  GGPermission.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionDefine.h"
#import "GGPermissionLogger.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGPermission : NSObject

+ (instancetype)shareInstance;

/// 是否自动弹窗引导去设置（默认 YES）
@property (nonatomic, assign) BOOL autoTipEnable;

/// 日志级别（便捷访问）
@property (nonatomic, assign) GGPermissionLogLevel logLevel;

#pragma mark - 各权限未开启时的提示文案

// 相机
@property (nonatomic, copy) NSString *cameraPushSettingTips;

// 相册
@property (nonatomic, copy) NSString *photoPushSettingTips;              // 读写
@property (nonatomic, copy) NSString *photoAddOnlyPushSettingTips;       // 只写

// 定位
@property (nonatomic, copy) NSString *locationWhenPushSettingTips;
@property (nonatomic, copy) NSString *locationAlwaysPushSettingTips;

// 麦克风
@property (nonatomic, copy) NSString *microphonePushSettingTips;

// 通讯录
@property (nonatomic, copy) NSString *contactsPushSettingTips;

// 通知
@property (nonatomic, copy) NSString *notificationPushSettingTips;

// 日历
@property (nonatomic, copy) NSString *calendarPushSettingTips;           // 完整访问
@property (nonatomic, copy) NSString *calendarWriteOnlyPushSettingTips;  // 只写

// 蓝牙
@property (nonatomic, copy) NSString *bluetoothPushSettingTips;

// 健康（细分）
@property (nonatomic, copy) NSString *healthPushSettingTips;             // 综合
@property (nonatomic, copy) NSString *healthStepsPushSettingTips;        // 步数
@property (nonatomic, copy) NSString *healthHeartRatePushSettingTips;    // 心率
@property (nonatomic, copy) NSString *healthSleepPushSettingTips;        // 睡眠
@property (nonatomic, copy) NSString *healthWorkoutPushSettingTips;      // 锻炼

/// 请求指定类型的系统权限
///
/// @param type 权限类型，详见 GGPermissionType
/// @param callback 结果回调，主线程执行
///
/// @note 如果已有请求在进行中，旧请求会被取消，其回调不会被触发。
/// @note 必须在主线程调用。
- (void)permissonType:(GGPermissionType)type withHandle:(GGPermissionCallback)callback;

@end

NS_ASSUME_NONNULL_END
