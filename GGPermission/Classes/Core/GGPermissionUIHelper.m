//
//  GGPermissionUIHelper.m
//  GGPermission
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermissionUIHelper.h"
#import "UIViewController+GGPermission.h"
#import "GGPermissionLoggerMacros.h"

static id _globalObserver = nil;
static dispatch_block_t _pendingGoSettingBlock = nil;
static const NSTimeInterval kPermissionSettingBackDelay = 0.3;

@implementation GGPermissionUIHelper

#pragma mark - 去设置弹框
+ (void)showSettingAlertWithTips:(NSString *)tips
                          cancel:(void(^)(void))cancel
                       goSetting:(void(^)(void))goSetting {
    if (!tips.length) {
        GGPermissionLogWarning(@"showSettingAlertWithTips: tips 为空");
        if (cancel) cancel();
        return;
    }
    
    // 清理上一轮残留监听和待执行延时回调
    [self removeGlobalObserverIfNeeded];
    [self cancelPendingGoSettingBlock];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:tips
                                                            preferredStyle:UIAlertControllerStyleAlert];
    __block BOOL didGoSetting = NO;
    
    // 取消按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"取消"
                                             style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * _Nonnull action) {
        GGPermissionLogInfo(@"用户点击：取消");
        [self removeGlobalObserverIfNeeded];
        [self cancelPendingGoSettingBlock];
        if (cancel) cancel();
    }]];
    
    // 去设置按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"去设置"
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * _Nonnull action) {
        GGPermissionLogInfo(@"用户点击：去设置");
        didGoSetting = YES;
        [self openSystemSetting];
    }]];
    
    // 只有传入 goSetting 回调，才注册前台监听
    if (goSetting) {
        __block BOOL hasTriggered = NO;
        id observer = [[NSNotificationCenter defaultCenter]
                       addObserverForName:UIApplicationDidBecomeActiveNotification
                                   object:nil
                                    queue:[NSOperationQueue mainQueue]
                               usingBlock:^(NSNotification * _Nonnull note) {
            if (hasTriggered) return;
            hasTriggered = YES;
            
            [self removeGlobalObserverIfNeeded];
            if (!didGoSetting) {
                GGPermissionLogDebug(@"用户未点'去设置'，忽略前台激活");
                return;
            }
            
            GGPermissionLogInfo(@"App 回到前台，准备重新读取权限状态");
            dispatch_block_t pending = ^{
                GGPermissionLogDebug(@"延迟 %.1fs 后触发 goSetting 回调", kPermissionSettingBackDelay);
                goSetting();
                _pendingGoSettingBlock = nil;
            };
            _pendingGoSettingBlock = pending;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                         (int64_t)(kPermissionSettingBackDelay * NSEC_PER_SEC)),
                           dispatch_get_main_queue(),
                           pending);
        }];
        _globalObserver = observer;
    }
    
    UIViewController *top = [UIViewController gg_topViewController];
    if (top) {
        [top presentViewController:alert animated:YES completion:nil];
    } else {
        GGPermissionLogWarning(@"showSettingAlertWithTips: 找不到顶层 VC，直接回调 cancel");
        [self removeGlobalObserverIfNeeded];
        [self cancelPendingGoSettingBlock];
        if (cancel) cancel();
    }
}

#pragma mark - 打开系统设置
+ (void)openSystemSetting {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            GGPermissionLogInfo(@"跳转系统设置 %@", success ? @"成功" : @"失败");
        }];
    } else {
        GGPermissionLogWarning(@"无法打开系统设置页");
    }
}

#pragma mark - Private
+ (void)removeGlobalObserverIfNeeded {
    if (_globalObserver) {
        GGPermissionLogDebug(@"移除全局通知监听");
        [[NSNotificationCenter defaultCenter] removeObserver:_globalObserver];
        _globalObserver = nil;
    }
}

+ (void)cancelPendingGoSettingBlock {
    if (_pendingGoSettingBlock) {
        GGPermissionLogDebug(@"取消待执行的 goSetting 延时回调");
        _pendingGoSettingBlock = nil;
    }
}

@end
