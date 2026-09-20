//
//  GGPermissionProtocol.h
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GGPermissionDefine.h"

/// 权限处理器协议（负责状态判断、分发、弹窗引导）
@protocol GGPermissionHandlerProtocol <NSObject>
@required
- (void)requestPermission:(GGPermissionType)type callback:(GGPermissionCallback)callback;
@optional
+ (BOOL)isAuthorized;
@end

/// 权限请求器协议（只负责调用系统 API 发起一次请求）
@protocol GGPermissionRequestProtocol <NSObject>
@required
- (void)startRequest:(GGPermissionType)type callback:(GGPermissionCallback)callback;
@end
