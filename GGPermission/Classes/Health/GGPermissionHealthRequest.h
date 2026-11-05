//
//  GGPermissionHealthRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 健康权限请求器：按数据类型发起请求。
 *
 * 回调约定：
 * - `granted = YES` 且 `statusCode = 0`：弹窗流程完成；
 * - `granted = NO`  且 `statusCode = 1`：用户拒绝或请求失败；
 * - `granted = NO`  且 `statusCode = GGPermissionErrorServiceDisabled`：
 *   设备不支持 HealthKit 或健康数据不可用。
 *
 * 注意：
 * - HealthKit 不提供同步查询授权状态的 API，`currentSystemStatus` 始终返回 nil；
 * - `granted = YES` 仅表示弹窗流程完成，不代表所有请求的数据类型都被同意；
 * - 具体数据类型是否可读，需在读取该类型数据时判断。
 */
@interface GGPermissionHealthRequest : GGPermissionBaseRequest

/// 请求类型（决定请求哪些 HKObjectType）
@property (nonatomic, assign) GGPermissionType healthType;

@end

NS_ASSUME_NONNULL_END
