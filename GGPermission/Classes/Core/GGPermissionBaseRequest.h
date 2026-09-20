//
//  GGPermissionBaseRequest.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGPermissionBaseRequest : NSObject <GGPermissionRequestProtocol>

/// 业务回调（子类可读写）
@property (nonatomic, copy, nullable) GGPermissionCallback callback;

/// 是否已取消（只读，子类通过 prepareForNewRequest 重置）
@property (nonatomic, assign, readonly) BOOL cancelled;
/// 是否已回调过（只读）
@property (nonatomic, assign, readonly) BOOL isCallbackExecuted;

/// 子类在 startRequest: 开头调用，重置所有状态
- (void)prepareForNewRequest;

/// 取消请求
- (void)cancel;

/// 子类重写：发起系统权限请求
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback;

/// 统一回调出口
- (void)executeCallback:(BOOL)granted statusCode:(NSNumber *)statusCode;

/// 子类重写：取消时清理平台资源
- (void)onCancel;

/// 子类重写：读取当前系统状态（超时时用）
- (nullable NSNumber *)currentSystemStatus;

/// 超时时间，默认 15 秒
- (NSTimeInterval)timeoutInterval;

/// 启动超时定时器（子类在 startRequest: 末尾调用）
- (void)startTimeoutIfNeeded;

@end

NS_ASSUME_NONNULL_END
