//
//  GGViewController.m
//  GGPermission_Example
//
//  Created by GG on 2026/9/18.
//  Copyright © 2026 github6022244. All rights reserved.
//

#import "GGViewController.h"
#import <GGPermission.h>
#import <GGPermissionLoggerMacros.h>

#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import <UserNotifications/UserNotifications.h>
#import <EventKit/EventKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <HealthKit/HealthKit.h>

#pragma mark - 测试项模型

@interface GGTestItem : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) NSInteger type;   // >=0 权限 type；-1/-2/-3/-4 工具项
+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         type:(NSInteger)type;
@end

@implementation GGTestItem
+ (instancetype)itemWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                         type:(NSInteger)type {
    GGTestItem *item = [[GGTestItem alloc] init];
    item.title = title;
    item.subtitle = subtitle;
    item.type = type;
    return item;
}
@end

#pragma mark - GGViewController

@interface GGViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSArray<GGTestItem *> *> *sections;
@property (nonatomic, strong) NSArray<NSString *> *sectionTitles;

@end

@implementation GGViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GGPermission 测试";
    self.view.backgroundColor = [UIColor systemBackgroundColor];

    [self setupSettings];
    [self setupData];
    [self setupTableView];
}

#pragma mark - 全局配置
- (void)setupSettings {
    GGPermission *p = [GGPermission shareInstance];
    p.autoTipEnable = YES;
    // 文案可自定义，不设置则用默认
}

#pragma mark - 数据
- (void)setupData {
    self.sectionTitles = @[
        @"相册",
        @"相机",
        @"麦克风",
        @"定位",
        @"通讯录",
        @"通知",
        @"日历",
        @"蓝牙",
        @"健康",
        @"并发 / 合并 / 取消",
        @"工具",
    ];

    self.sections = @[
        // 相册
        @[
            [GGTestItem itemWithTitle:@"相册（读写）"
                             subtitle:@"GGPermissionTypePhoto"
                                 type:GGPermissionTypePhoto],
            [GGTestItem itemWithTitle:@"相册（只写）"
                             subtitle:@"GGPermissionTypePhotoAddOnly"
                                 type:GGPermissionTypePhotoAddOnly],
        ],
        // 相机
        @[
            [GGTestItem itemWithTitle:@"相机"
                             subtitle:@"GGPermissionTypeCamera"
                                 type:GGPermissionTypeCamera],
        ],
        // 麦克风
        @[
            [GGTestItem itemWithTitle:@"麦克风"
                             subtitle:@"GGPermissionTypeMicrophone"
                                 type:GGPermissionTypeMicrophone],
        ],
        // 定位
        @[
            [GGTestItem itemWithTitle:@"定位（使用期间）"
                             subtitle:@"GGPermissionTypeLocationWhen"
                                 type:GGPermissionTypeLocationWhen],
            [GGTestItem itemWithTitle:@"定位（始终）"
                             subtitle:@"GGPermissionTypeLocationAlways"
                                 type:GGPermissionTypeLocationAlways],
        ],
        // 通讯录
        @[
            [GGTestItem itemWithTitle:@"通讯录"
                             subtitle:@"GGPermissionTypeContacts"
                                 type:GGPermissionTypeContacts],
        ],
        // 通知
        @[
            [GGTestItem itemWithTitle:@"通知"
                             subtitle:@"GGPermissionTypeNotification"
                                 type:GGPermissionTypeNotification],
        ],
        // 日历
        @[
            [GGTestItem itemWithTitle:@"日历（完整访问）"
                             subtitle:@"GGPermissionTypeCalendarFullAccess"
                                 type:GGPermissionTypeCalendarFullAccess],
            [GGTestItem itemWithTitle:@"日历（只写）"
                             subtitle:@"GGPermissionTypeCalendarWriteOnly"
                                 type:GGPermissionTypeCalendarWriteOnly],
        ],
        // 蓝牙
        @[
            [GGTestItem itemWithTitle:@"蓝牙"
                             subtitle:@"GGPermissionTypeBluetooth"
                                 type:GGPermissionTypeBluetooth],
        ],
        // 健康
        @[
            [GGTestItem itemWithTitle:@"健康（综合）"
                             subtitle:@"GGPermissionTypeHealth"
                                 type:GGPermissionTypeHealth],
            [GGTestItem itemWithTitle:@"健康（步数）"
                             subtitle:@"GGPermissionTypeHealthSteps"
                                 type:GGPermissionTypeHealthSteps],
            [GGTestItem itemWithTitle:@"健康（心率）"
                             subtitle:@"GGPermissionTypeHealthHeartRate"
                                 type:GGPermissionTypeHealthHeartRate],
            [GGTestItem itemWithTitle:@"健康（睡眠）"
                             subtitle:@"GGPermissionTypeHealthSleep"
                                 type:GGPermissionTypeHealthSleep],
            [GGTestItem itemWithTitle:@"健康（锻炼）"
                             subtitle:@"GGPermissionTypeHealthWorkout"
                                 type:GGPermissionTypeHealthWorkout],
        ],
        // 并发 / 合并 / 取消（新逻辑专项）
        @[
            [GGTestItem itemWithTitle:@"同 type 合并（连续两次定位）"
                             subtitle:@"两个回调都应触发，共享一次系统弹窗"
                                 type:-2],
            [GGTestItem itemWithTitle:@"不同 type 排队（定位 + 相机）"
                             subtitle:@"定位先执行，相机排队；两者都回调"
                                 type:-3],
            [GGTestItem itemWithTitle:@"主动取消指定 type（定位）"
                             subtitle:@"cancelTaskWithType: 定位，应回调 Cancelled"
                                 type:-4],
            [GGTestItem itemWithTitle:@"主动取消全部"
                             subtitle:@"cancelAllTasks，所有活跃请求应回调 Cancelled"
                                 type:-5],
        ],
        // 工具
        @[
            [GGTestItem itemWithTitle:@"请求未引入的权限（测试 Unknown）"
                             subtitle:@"请求一个未引入 subspec 的 type"
                                 type:-6],
        ],
    ];
}

#pragma mark - UI
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitles[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"GGTestCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.numberOfLines = 0;
    }

    GGTestItem *item = self.sections[indexPath.section][indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = item.subtitle;
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    GGTestItem *item = self.sections[indexPath.section][indexPath.row];

    switch (item.type) {
        case -2:
            [self testSameTypeMerge];
            break;
        case -3:
            [self testDifferentTypeQueue];
            break;
        case -4:
            [self testCancelSpecificType];
            break;
        case -5:
            [self testCancelAll];
            break;
        case -6:
            [self testUnknownSubspec];
            break;
        default:
            [self requestPermissionWithType:(GGPermissionType)item.type
                                      title:item.title];
            break;
    }
}

#pragma mark - 单个权限请求
- (void)requestPermissionWithType:(GGPermissionType)type title:(NSString *)title {
    GGPermissionLogDebug(@"▶️ 请求权限：%@ (type=%ld)", title, (long)type);

    __weak typeof(self) ws = self;
    [[GGPermission shareInstance] permissonType:type
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;

        NSString *desc = [strongSelf descForStatusCode:statusCode type:type];
        NSString *msg = [NSString stringWithFormat:
                         @"权限：%@\n"
                         @"结果：%@\n"
                         @"statusCode：%@\n"
                         @"说明：%@",
                         title,
                         granted ? @"✅ 已授权" : @"❌ 未授权",
                         statusCode,
                         desc];

        GGPermissionLogDebug(@"◀️ 回调：%@\n%@", title, msg);
        [strongSelf showAlertWithTitle:title message:msg];
    }];
}

#pragma mark - 工具项：同 type 合并（连续两次定位）
- (void)testSameTypeMerge {
    GGPermissionLogDebug(@"🧪 同 type 合并测试：连续两次请求定位（When），预期两个回调都触发，且只弹一次系统权限框（若未确定）");

    __weak typeof(self) ws = self;
    __block NSInteger callbackCount = 0;
    NSInteger expected = 2;

    GGPermissionCallback firstCallback = ^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        callbackCount += 1;
        GGPermissionLogDebug(@"📍 第一次定位回调 granted=%d status=%@（第 %ld/%ld 次）",
                             granted, statusCode, (long)callbackCount, (long)expected);
        if (callbackCount == expected) {
            [strongSelf showAlertWithTitle:@"同 type 合并测试"
                                 message:[NSString stringWithFormat:
                                          @"连续两次请求定位（When）\n\n"
                                          @"预期行为：\n"
                                          @"- 两次请求合并为一个 Task\n"
                                          @"- 共享一次系统弹窗（若未确定）\n"
                                          @"- 两个回调都触发\n\n"
                                          @"实际回调次数：%ld / %ld",
                                          (long)callbackCount, (long)expected]];
        }
    };

    GGPermissionCallback secondCallback = ^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        callbackCount += 1;
        GGPermissionLogDebug(@"📍 第二次定位回调 granted=%d status=%@（第 %ld/%ld 次）",
                             granted, statusCode, (long)callbackCount, (long)expected);
        if (callbackCount == expected) {
            [strongSelf showAlertWithTitle:@"同 type 合并测试"
                                 message:[NSString stringWithFormat:
                                          @"连续两次请求定位（When）\n\n"
                                          @"预期行为：\n"
                                          @"- 两次请求合并为一个 Task\n"
                                          @"- 共享一次系统弹窗（若未确定）\n"
                                          @"- 两个回调都触发\n\n"
                                          @"实际回调次数：%ld / %ld",
                                          (long)callbackCount, (long)expected]];
        }
    };

    [[GGPermission shareInstance] permissonType:GGPermissionTypeLocationWhen
                                     withHandle:firstCallback];
    [[GGPermission shareInstance] permissonType:GGPermissionTypeLocationWhen
                                     withHandle:secondCallback];

    [self showAlertWithTitle:@"同 type 合并测试"
                     message:@"已连续发起两次定位（When）请求\n\n请查看 Xcode 控制台日志，并等待两个回调"];
}

#pragma mark - 工具项：不同 type 排队（定位 + 相机）
- (void)testDifferentTypeQueue {
    GGPermissionLogDebug(@"🧪 不同 type 排队测试：先定位（When），0.1s 后相机，预期定位先执行、相机排队、两者都回调");

    __weak typeof(self) ws = self;
    __block NSInteger callbackCount = 0;
    NSInteger expected = 2;

    GGPermissionCallback checkCompletion = ^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        callbackCount += 1;
        if (callbackCount == expected) {
            [strongSelf showAlertWithTitle:@"不同 type 排队测试"
                                 message:[NSString stringWithFormat:
                                          @"先定位（When），0.1s 后相机\n\n"
                                          @"预期行为：\n"
                                          @"- 定位先执行\n"
                                          @"- 相机排队，定位结束后执行\n"
                                          @"- 两者都回调，不会被取消\n\n"
                                          @"实际回调次数：%ld / %ld",
                                          (long)callbackCount, (long)expected]];
        }
    };

    [[GGPermission shareInstance] permissonType:GGPermissionTypeLocationWhen
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        GGPermissionLogDebug(@"📍 定位回调 granted=%d status=%@", granted, statusCode);
        checkCompletion(granted, statusCode);
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [[GGPermission shareInstance] permissonType:GGPermissionTypeCamera
                                         withHandle:^(BOOL granted, NSNumber *statusCode) {
            GGPermissionLogDebug(@"📷 相机回调 granted=%d status=%@", granted, statusCode);
            checkCompletion(granted, statusCode);
        }];
    });

    [self showAlertWithTitle:@"不同 type 排队测试"
                     message:@"已发起：定位（When）\n0.1s 后将发起：相机\n\n请查看 Xcode 控制台日志"];
}

#pragma mark - 工具项：主动取消指定 type
- (void)testCancelSpecificType {
    GGPermissionLogDebug(@"🧪 主动取消测试：发起定位（When）后立即 cancelTaskWithType:，预期回调 Cancelled");

    __weak typeof(self) ws = self;
    [[GGPermission shareInstance] permissonType:GGPermissionTypeLocationWhen
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        BOOL cancelled = (statusCode.integerValue == GGPermissionErrorCancelled);
        GGPermissionLogDebug(@"📍 定位回调 granted=%d status=%@（cancelled=%@）",
                             granted, statusCode, cancelled ? @"YES" : @"NO");
        [strongSelf showAlertWithTitle:@"主动取消指定 type 测试"
                             message:[NSString stringWithFormat:
                                      @"发起定位后立即 cancelTaskWithType:\n\n"
                                      @"预期行为：\n"
                                      @"- 定位回调触发\n"
                                      @"- statusCode = GGPermissionErrorCancelled（-5）\n\n"
                                      @"实际结果：\n"
                                      @"granted = %@\n"
                                      @"statusCode = %@\n"
                                      @"是否 Cancelled：%@",
                                      granted ? @"YES" : @"NO",
                                      statusCode,
                                      cancelled ? @"✅ 是" : @"❌ 否"]];
    }];

    [[GGPermission shareInstance] cancelTaskWithType:GGPermissionTypeLocationWhen];

    [self showAlertWithTitle:@"主动取消指定 type 测试"
                     message:@"已发起定位并立即取消\n\n请查看 Xcode 控制台日志"];
}

#pragma mark - 工具项：主动取消全部
- (void)testCancelAll {
    GGPermissionLogDebug(@"🧪 主动取消全部：先发起定位 + 相机，再立即 cancelAllTasks，预期两个回调都收到 Cancelled");

    __weak typeof(self) ws = self;
    __block NSInteger callbackCount = 0;
    NSInteger expected = 2;

    GGPermissionCallback checkCompletion = ^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;
        callbackCount += 1;
        BOOL cancelled = (statusCode.integerValue == GGPermissionErrorCancelled);
        GGPermissionLogDebug(@"🔔 回调 granted=%d status=%@ cancelled=%@（第 %ld/%ld 次）",
                             granted, statusCode, cancelled ? @"YES" : @"NO",
                             (long)callbackCount, (long)expected);
        if (callbackCount == expected) {
            [strongSelf showAlertWithTitle:@"主动取消全部测试"
                                 message:[NSString stringWithFormat:
                                          @"发起定位 + 相机后立即 cancelAllTasks\n\n"
                                          @"预期行为：\n"
                                          @"- 两个请求都回调\n"
                                          @"- statusCode = GGPermissionErrorCancelled（-5）\n\n"
                                          @"实际回调次数：%ld / %ld",
                                          (long)callbackCount, (long)expected]];
        }
    };

    [[GGPermission shareInstance] permissonType:GGPermissionTypeLocationWhen
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        checkCompletion(granted, statusCode);
    }];
    [[GGPermission shareInstance] permissonType:GGPermissionTypeCamera
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        checkCompletion(granted, statusCode);
    }];

    [[GGPermission shareInstance] cancelAllTasks];

    [self showAlertWithTitle:@"主动取消全部测试"
                     message:@"已发起定位 + 相机并立即取消全部\n\n请查看 Xcode 控制台日志"];
}

#pragma mark - 工具项：请求未引入的 subspec
- (void)testUnknownSubspec {
    // 故意请求一个可能未引入的 type
    // 如果 Podfile 未引入对应 subspec，会返回 Unknown
    GGPermissionType type = GGPermissionTypeBluetooth;

    __weak typeof(self) ws = self;
    [[GGPermission shareInstance] permissonType:type
                                     withHandle:^(BOOL granted, NSNumber *statusCode) {
        __strong typeof(ws) strongSelf = ws;
        if (!strongSelf) return;

        NSString *msg;
        if (statusCode.integerValue == GGPermissionErrorUnknown) {
            msg = @"返回 Unknown ✅\n说明当前未引入 Bluetooth subspec，符合预期。";
        } else {
            msg = [NSString stringWithFormat:@"返回正常状态：%@\n说明已引入 Bluetooth subspec。", statusCode];
        }
        [strongSelf showAlertWithTitle:@"未引入 subspec 测试" message:msg];
    }];
}

#pragma mark - 状态码说明
- (NSString *)descForStatusCode:(NSNumber *)statusCode type:(GGPermissionType)type {
    NSInteger code = statusCode.integerValue;

    // ========== 工具类内部错误（负数）==========
    if (code < 0) {
        switch (code) {
            case GGPermissionErrorUnknown:
                return @"未知错误 / 未引入对应 subspec（请检查 Podfile）";
            case GGPermissionErrorServiceDisabled:
                return @"系统级服务被禁用（如定位总开关关闭、健康数据不可用）";
            case GGPermissionErrorTimeout:
                return @"请求超时（15s 内系统未回调）";
            case GGPermissionErrorNoTopViewController:
                return @"找不到顶层 VC，无法弹窗引导";
            case GGPermissionErrorCancelled:
                return @"请求被取消（新请求覆盖 / 主动 cancelTask / cancelAll）";
            default:
                return [NSString stringWithFormat:@"其他内部错误（%ld）", (long)code];
        }
    }

    // ========== 系统原始状态（非负）==========
    switch (type) {

        // ---------- 相册 ----------
        case GGPermissionTypePhoto: {
            PHAuthorizationStatus s = (PHAuthorizationStatus)code;
            switch (s) {
                case PHAuthorizationStatusNotDetermined: return @"相册（读写）：未确定";
                case PHAuthorizationStatusRestricted:    return @"相册（读写）：受限（家长控制等）";
                case PHAuthorizationStatusDenied:        return @"相册（读写）：已拒绝";
                case PHAuthorizationStatusAuthorized:    return @"相册（读写）：已授权（完全访问）";
                case PHAuthorizationStatusLimited:       return @"相册（读写）：受限访问（仅选中照片，iOS 14+）";
                default:                                 return [NSString stringWithFormat:@"相册（读写）：未知状态（%ld）", (long)s];
            }
        }
        case GGPermissionTypePhotoAddOnly: {
            PHAuthorizationStatus s = (PHAuthorizationStatus)code;
            switch (s) {
                case PHAuthorizationStatusNotDetermined: return @"相册（只写）：未确定";
                case PHAuthorizationStatusRestricted:    return @"相册（只写）：受限（家长控制等）";
                case PHAuthorizationStatusDenied:        return @"相册（只写）：已拒绝";
                case PHAuthorizationStatusAuthorized:    return @"相册（只写）：已授权";
                default:                                 return [NSString stringWithFormat:@"相册（只写）：未知状态（%ld）", (long)s];
            }
        }

        // ---------- 相机 / 麦克风 ----------
        case GGPermissionTypeCamera: {
            AVAuthorizationStatus s = (AVAuthorizationStatus)code;
            switch (s) {
                case AVAuthorizationStatusNotDetermined: return @"相机：未确定";
                case AVAuthorizationStatusRestricted:    return @"相机：受限（家长控制等）";
                case AVAuthorizationStatusDenied:        return @"相机：已拒绝";
                case AVAuthorizationStatusAuthorized:    return @"相机：已授权";
                default:                                 return @"相机：未知状态";
            }
        }
        case GGPermissionTypeMicrophone: {
            AVAuthorizationStatus s = (AVAuthorizationStatus)code;
            switch (s) {
                case AVAuthorizationStatusNotDetermined: return @"麦克风：未确定";
                case AVAuthorizationStatusRestricted:    return @"麦克风：受限（家长控制等）";
                case AVAuthorizationStatusDenied:        return @"麦克风：已拒绝";
                case AVAuthorizationStatusAuthorized:    return @"麦克风：已授权";
                default:                                 return @"麦克风：未知状态";
            }
        }

        // ---------- 定位 ----------
        case GGPermissionTypeLocationWhen:
        case GGPermissionTypeLocationAlways: {
            CLAuthorizationStatus s = (CLAuthorizationStatus)code;
            switch (s) {
                case kCLAuthorizationStatusNotDetermined:      return @"定位：未确定";
                case kCLAuthorizationStatusRestricted:         return @"定位：受限（家长控制等）";
                case kCLAuthorizationStatusDenied:             return @"定位：已拒绝";
                case kCLAuthorizationStatusAuthorizedAlways:   return @"定位：始终允许";
                case kCLAuthorizationStatusAuthorizedWhenInUse:return @"定位：使用期间允许";
                default:                                       return @"定位：未知状态";
            }
        }

        // ---------- 通讯录 ----------
        case GGPermissionTypeContacts: {
            CNAuthorizationStatus s = (CNAuthorizationStatus)code;
            switch (s) {
                case CNAuthorizationStatusNotDetermined:
                    return @"通讯录：未确定";
                case CNAuthorizationStatusRestricted:
                    return @"通讯录：受限（家长控制等）";
                case CNAuthorizationStatusDenied:
                    return @"通讯录：已拒绝";
                case CNAuthorizationStatusAuthorized:
                    return @"通讯录：已授权（完全访问）";
                case CNAuthorizationStatusLimited:
                    if (@available(iOS 18.0, *)) {
                        return @"通讯录：受限访问（仅选中联系人，iOS 18+）";
                    }
                    return [NSString stringWithFormat:@"通讯录：未知状态（%ld）", (long)s];
                default:
                    return [NSString stringWithFormat:@"通讯录：未知状态（%ld）", (long)s];
            }
        }

        // ---------- 通知 ----------
        case GGPermissionTypeNotification: {
            UNAuthorizationStatus s = (UNAuthorizationStatus)code;
            switch (s) {
                case UNAuthorizationStatusNotDetermined: return @"通知：未确定";
                case UNAuthorizationStatusDenied:        return @"通知：已拒绝";
                case UNAuthorizationStatusAuthorized:    return @"通知：已授权";
                case UNAuthorizationStatusProvisional:   return @"通知：临时授权（Provisional，iOS 12+）";
                case UNAuthorizationStatusEphemeral:     return @"通知：临时授权（Ephemeral，App Clip）";
                default:                                 return @"通知：未知状态";
            }
        }

        // ---------- 日历 ----------
        case GGPermissionTypeCalendarFullAccess:
        case GGPermissionTypeCalendarWriteOnly: {
            EKAuthorizationStatus s = (EKAuthorizationStatus)code;
            switch (s) {
                case EKAuthorizationStatusNotDetermined:
                    return @"日历：未确定";
                case EKAuthorizationStatusRestricted:
                    return @"日历：受限（家长控制等）";
                case EKAuthorizationStatusDenied:
                    return @"日历：已拒绝";
                case EKAuthorizationStatusFullAccess:
                    if (@available(iOS 17.0, *)) {
                        return @"日历：完整访问（当前为完整访问，包含写能力）";
                    }
                    return @"日历：已授权（当前为完整访问，包含写能力）";
                case EKAuthorizationStatusWriteOnly:
                    return @"日历：只写访问（iOS 17+）";
                default:
                    return [NSString stringWithFormat:@"日历：未知状态（%ld）", (long)s];
            }
        }

        // ---------- 蓝牙 ----------
        case GGPermissionTypeBluetooth: {
            if (@available(iOS 13.0, *)) {
                CBManagerAuthorization s = (CBManagerAuthorization)code;
                switch (s) {
                    case CBManagerAuthorizationNotDetermined:  return @"蓝牙：未确定";
                    case CBManagerAuthorizationRestricted:     return @"蓝牙：受限（家长控制等）";
                    case CBManagerAuthorizationDenied:         return @"蓝牙：已拒绝";
                    case CBManagerAuthorizationAllowedAlways:  return @"蓝牙：已授权";
                    default:                                   return @"蓝牙：未知状态";
                }
            }
            return @"蓝牙：未知状态（iOS 13 以下无此枚举）";
        }

        // ---------- 健康 ----------
        case GGPermissionTypeHealth:
        case GGPermissionTypeHealthSteps:
        case GGPermissionTypeHealthHeartRate:
        case GGPermissionTypeHealthSleep:
        case GGPermissionTypeHealthWorkout: {
            switch (code) {
                case 0:  return @"健康：弹窗流程已完成（注意：不代表所有类型都被同意，需读数据时判断）";
                case 1:  return @"健康：用户拒绝 / 请求失败";
                default: return [NSString stringWithFormat:@"健康：未知状态（%ld）", (long)code];
            }
        }

        default:
            return [NSString stringWithFormat:@"未知权限类型（type=%ld, code=%ld）", (long)type, (long)code];
    }
}

#pragma mark - Alert
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];

        UIViewController *top = self;
        while (top.presentedViewController) {
            top = top.presentedViewController;
        }
        [top presentViewController:alert animated:YES completion:nil];
    });
}

@end
