# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'DocSign' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DocSign

pod 'SVProgressHUD'
pod 'XMLCoder'


end

target 'OneSignalNotificationServiceExtension' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OneSignalNotificationServiceExtension

end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
            config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
        end
    end
end
