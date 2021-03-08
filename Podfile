# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'

target 'ReactiveExtensionsDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ReactiveExtensionsDemo
  pod 'RxSwift'
  pod 'RxDataSources'
  pod 'SDWebImage'

  target 'ReactiveExtensionsDemoTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'ReactiveExtensionsDemoUITests' do
    # Pods for testing
  end

end

post_install do | installer |
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
             config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
             config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
    end
end
