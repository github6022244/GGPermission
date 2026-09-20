#
# Be sure to run `pod lib lint GGPermission.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GGPermission'
  s.version          = '1.0.1'
  s.summary          = '按需引入的权限请求工具'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  封装iOS权限请求工具类
                       DESC

  s.homepage         = 'https://github.com/github6022244/GGPermission.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'github6022244' => '1563084860@qq.com' }
  s.source           = { :git => 'https://github.com/github6022244/GGPermission.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'

#  s.source_files = 'GGPermission/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GGPermission' => ['GGPermission/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'GGWindowManager'
  
  # 默认只引 Core（不指定 subspecs 时）
  s.default_subspecs = 'Core'

  # ===== Core（必选）=====
  s.subspec 'Core' do |core|
    core.source_files = 'GGPermission/Classes/Core/**/*.{h,m}'
    core.frameworks   = 'UIKit', 'Foundation'
  end

  # ===== 相册 =====
  s.subspec 'Photo' do |sp|
    sp.source_files = 'GGPermission/Classes/Photo/**/*.{h,m}'
    sp.frameworks   = 'Photos'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 相机 =====
  s.subspec 'Camera' do |sp|
    sp.source_files = 'GGPermission/Classes/Camera/**/*.{h,m}'
    sp.frameworks   = 'AVFoundation'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 定位 =====
  s.subspec 'Location' do |sp|
    sp.source_files = 'GGPermission/Classes/Location/**/*.{h,m}'
    sp.frameworks   = 'CoreLocation'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 麦克风 =====
  s.subspec 'Microphone' do |sp|
    sp.source_files = 'GGPermission/Classes/Microphone/**/*.{h,m}'
    sp.frameworks   = 'AVFoundation'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 通讯录 =====
  s.subspec 'Contacts' do |sp|
    sp.source_files = 'GGPermission/Classes/Contacts/**/*.{h,m}'
    sp.frameworks   = 'Contacts'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 通知 =====
  s.subspec 'Notification' do |sp|
    sp.source_files = 'GGPermission/Classes/Notification/**/*.{h,m}'
    sp.frameworks   = 'UserNotifications'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 日历 =====
  s.subspec 'Calendar' do |sp|
    sp.source_files = 'GGPermission/Classes/Calendar/**/*.{h,m}'
    sp.frameworks   = 'EventKit'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 蓝牙 =====
  s.subspec 'Bluetooth' do |sp|
    sp.source_files = 'GGPermission/Classes/Bluetooth/**/*.{h,m}'
    sp.frameworks   = 'CoreBluetooth'
    sp.dependency     'GGPermission/Core'
  end

  # ===== 健康 =====
  s.subspec 'Health' do |sp|
    sp.source_files = 'GGPermission/Classes/Health/**/*.{h,m}'
    sp.frameworks   = 'HealthKit'
    sp.dependency     'GGPermission/Core'
  end
end
