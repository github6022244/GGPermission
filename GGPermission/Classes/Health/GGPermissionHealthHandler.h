//
//  GGPermissionHealthHandler.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/20.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionBaseHandler.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 健康权限 Handler。
 *
 * HealthKit 限制：
 * - 无法同步查询授权状态，`currentSystemStatus` 返回 nil，直接走 Request；
 * - `requestAuthorizationToShareTypes:readTypes:completion:` 的回调只表示
 *   “弹窗流程是否完成”，不代表用户同意了所有请求的数据类型；
 * - 用户是否真正同意某个数据类型，需在读取该类型数据时判断。
 *
 * 回调约定：
 * - `granted = YES` 且 `statusCode = 0`：弹窗流程完成；
 * - `granted = NO`  且 `statusCode = 1`：用户拒绝或请求失败；
 * - `statusCode` 不使用 HealthKit 原始状态（HealthKit 不提供同步状态查询）。
 */
@interface GGPermissionHealthHandler : GGPermissionBaseHandler

@end

NS_ASSUME_NONNULL_END
