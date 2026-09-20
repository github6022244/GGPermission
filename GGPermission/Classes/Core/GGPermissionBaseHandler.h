//
//  GGPermissionBaseHandler.h
//  GGPermission
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionProtocol.h"
#import "GGPermissionBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

/// 所有权限 Handler 的基类，封装 currentRequest 管理与引导设置
@interface GGPermissionBaseHandler : NSObject <GGPermissionHandlerProtocol>

/// 当前正在进行的 Request（子类通过 startRequestWithType:callback: 使用）
@property (nonatomic, strong, nullable) GGPermissionBaseRequest *currentRequest;

#pragma mark - 子类必须重写

/// 子类重写：创建新的 Request 实例
- (GGPermissionBaseRequest *)createRequest;

/// 子类重写：读取当前系统授权状态
/// 返回 nil 表示"未确定"或"无法同步查询"，需要发起请求
- (nullable NSNumber *)currentSystemStatus;

/// 子类重写：把系统状态转成 BOOL granted
- (BOOL)isGrantedForStatus:(NSNumber *)statusCode;

/// 子类重写：是否为"已拒绝/受限"状态（需要引导设置）
- (BOOL)isDeniedOrRestrictedForStatus:(NSNumber *)statusCode;

/// 子类重写：获取该权限的引导文案
- (NSString *)guideTipsForType:(GGPermissionType)type;

#pragma mark - 子类可调用

/// 统一的权限请求入口（子类在 requestPermission: 里调用）
- (void)startRequestWithType:(GGPermissionType)type callback:(GGPermissionCallback)callback;

/// 统一引导设置弹窗
- (void)guideToSettingWithType:(GGPermissionType)type
                        status:(NSNumber *)status
                      callback:(GGPermissionCallback)callback;

@end

NS_ASSUME_NONNULL_END
