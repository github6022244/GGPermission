//
//  GGPermission.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGPermission.h"
#import "GGPermissionProtocol.h"
#import "GGPermissionLoggerMacros.h"

@interface GGPermission ()
@property (nonatomic, copy) GGPermissionCallback block;
@property (nonatomic, assign) BOOL isCallbackExecuted;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id<GGPermissionHandlerProtocol>> *handlerMap;
@end

@implementation GGPermission

static GGPermission *_instance;

#pragma mark - Singleton
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self shareInstance];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[self class] shareInstance];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return [[self class] shareInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        _autoTipEnable = YES;

        _cameraPushSettingTips = @"相机权限未开启，是否前往设置";
        _photoPushSettingTips = @"相册权限未开启，是否前往设置";
        _photoAddOnlyPushSettingTips = @"相册写入权限未开启，是否前往设置";
        _locationWhenPushSettingTips = @"位置权限未开启，是否前往设置";
        _locationAlwaysPushSettingTips = @"始终允许位置权限未开启，是否前往设置";
        _microphonePushSettingTips = @"麦克风权限未开启，是否前往设置";
        _contactsPushSettingTips = @"通讯录权限未开启，是否前往设置";
        _notificationPushSettingTips = @"通知权限未开启，是否前往设置";
        _calendarPushSettingTips = @"日历权限未开启，是否前往设置";
        _calendarWriteOnlyPushSettingTips = @"日历写入权限未开启，是否前往设置";
        _bluetoothPushSettingTips = @"蓝牙权限未开启，是否前往设置";
        _healthPushSettingTips = @"健康权限未开启，是否前往设置";
        _healthStepsPushSettingTips = @"步数权限未开启，是否前往设置";
        _healthHeartRatePushSettingTips = @"心率权限未开启，是否前往设置";
        _healthSleepPushSettingTips = @"睡眠权限未开启，是否前往设置";
        _healthWorkoutPushSettingTips = @"锻炼权限未开启，是否前往设置";

        _isCallbackExecuted = NO;
        _handlerMap = [NSMutableDictionary dictionary];
        [self registerHandlers];
    }
    return self;
}

#pragma mark - 注册所有已编译进来的 Handler
- (void)registerHandlers {
    NSDictionary<NSString *, NSArray<NSNumber *> *> *map = @{
        @"GGPermissionPhotoHandler":        @[@(GGPermissionTypePhoto),
                                              @(GGPermissionTypePhotoAddOnly)],
        @"GGPermissionCameraHandler":       @[@(GGPermissionTypeCamera)],
        @"GGPermissionLocationHandler":     @[@(GGPermissionTypeLocationWhen),
                                              @(GGPermissionTypeLocationAlways)],
        @"GGPermissionMicrophoneHandler":   @[@(GGPermissionTypeMicrophone)],
        @"GGPermissionContactsHandler":     @[@(GGPermissionTypeContacts)],
        @"GGPermissionNotificationHandler": @[@(GGPermissionTypeNotification)],
        @"GGPermissionCalendarHandler":     @[@(GGPermissionTypeCalendarFullAccess),
                                              @(GGPermissionTypeCalendarWriteOnly)],
        @"GGPermissionBluetoothHandler":    @[@(GGPermissionTypeBluetooth)],
        @"GGPermissionHealthHandler":       @[@(GGPermissionTypeHealth),
                                              @(GGPermissionTypeHealthSteps),
                                              @(GGPermissionTypeHealthHeartRate),
                                              @(GGPermissionTypeHealthSleep),
                                              @(GGPermissionTypeHealthWorkout)],
    };

    [map enumerateKeysAndObjectsUsingBlock:^(NSString *clsName,
                                             NSArray<NSNumber *> *types,
                                             BOOL *stop) {
        Class cls = NSClassFromString(clsName);
        if (!cls) {
            GGPermissionLogInfo(@"%@ 类不存在，跳过注册", clsName);
            return;
        }
        for (NSNumber *t in types) {
            id handler = [[cls alloc] init];
            if (![handler conformsToProtocol:@protocol(GGPermissionHandlerProtocol)]) {
                GGPermissionLogInfo(@"%@ 对象未遵循 Handler 协议，跳过注册", clsName);
                continue;
            }
            self.handlerMap[t] = handler;
        }
    }];
}

#pragma mark - Public
- (void)permissonType:(GGPermissionType)type withHandle:(GGPermissionCallback)callback {
    // 主线程保护
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self permissonType:type withHandle:callback];
        });
        return;
    }

    if (self.block && self.block != callback) {
        GGPermissionLogWarning(@"丢弃未完成的旧权限请求");
        self.block = nil;
    }
    self.block = callback;
    self.isCallbackExecuted = NO;

    id<GGPermissionHandlerProtocol> handler = self.handlerMap[@(type)];
    if (!handler) {
        GGPermissionLogError(@"未引入 %ld 对应的 subspec，请在 Podfile 中添加", (long)type);
        [self executeBlock:NO statusCode:@(GGPermissionErrorUnknown)];
        return;
    }

    __weak typeof(self) ws = self;
    [handler requestPermission:type callback:^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        [strongSelf executeBlock:granted statusCode:statusCode];
    }];
}

#pragma mark - 统一回调
- (void)executeBlock:(BOOL)granted statusCode:(NSNumber *)statusCode {
    if (self.isCallbackExecuted) {
        GGPermissionLogWarning(@"重复回调被忽略");
        return;
    }
    self.isCallbackExecuted = YES;

    GGPermissionCallback cb = self.block;
    self.block = nil;
    if (cb) cb(granted, statusCode);
}

#pragma mark - set/get
- (void)setLogLevel:(GGPermissionLogLevel)logLevel {
    [GGPermissionLogger sharedLogger].logLevel = logLevel;
}

- (GGPermissionLogLevel)logLevel {
    return [GGPermissionLogger sharedLogger].logLevel;
}

@end
