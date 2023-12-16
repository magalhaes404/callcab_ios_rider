# Uncomment the next line to define a global platform for your project
platform :ios, '8.0'

target 'NewTaxi' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  project 'NewTaxi.xcodeproj'
  
  # Pods for NewTaxi
  pod 'AGPullView'
  pod 'GoogleMaps'#,'~> 3.9.0'
  pod 'GooglePlaces','~> 3.5.0'
  
  pod 'GoogleSignIn', '~> 5.0.2'
  #pod 'FBSDKLoginKit' // Dependency Package added
  pod 'SDWebImage'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/Database'
  #pod 'JSQMessagesViewController'
  pod 'GeoFire'
  pod 'Alamofire'
  pod 'TTTAttributedLabel'
  
  
  pod 'SinchRTC', '~> 4.2.6'
  
  
  #pod 'Fabric'
  #pod 'Crashlytics'
  
  # (Recommended) Pod for Google Analytics
  pod 'Firebase/Analytics'
  pod 'Firebase/Crashlytics'
  pod 'Braintree', '~> 4.37.0'
  pod 'BraintreeDropIn', '~> 8.1.3'
  pod 'Stripe', '~> 22.8.4'
  pod 'Firebase/Auth'
  pod 'ARCarMovement'
  pod 'lottie-ios', '~> 3.1'
  pod 'IQKeyboardManagerSwift'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
end
