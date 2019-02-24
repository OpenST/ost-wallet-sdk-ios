# Uncomment the next line to define a global platform for your project
platform :ios, '9.0'

target 'CryptoEthereumSwift' do
  workspace 'OstSdk.xcworkspace'
  project './CryptoEthereumSwift/CryptoEthereumSwift.xcodeproj'
  
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CryptoEthereumSwift
  pod 'CryptoSwift', '0.14.0'

  target 'CryptoEthereumSwiftExample' do
    inherit! :search_paths
    # Pods for example
  end

end

target 'EthereumKit' do
  project 'EthereumKit/EthereumKit.xcodeproj'
  workspace 'OstSdk.xcworkspace'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for EthereumKit

  target 'EthereumKitTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EthereumKitExample' do
    inherit! :search_paths
    # Pods for EthereumKitExample
    pod 'CryptoSwift', '0.14.0'
  end

  pod 'CryptoSwift', '0.14.0'

end

target 'OstSdk' do
  project 'OstSdk.xcodeproj'
  workspace 'OstSdk.xcworkspace'
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for OstSdk

  target 'OstSdkTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'CryptoSwift', '0.14.0'
    pod 'Alamofire', '4.8.1'
    pod 'BigInt', '3.1.0'
    pod 'FMDB', '2.7.5'
  end

  target 'OstSdkExample' do
    project 'OstSdk.xcodeproj'
    workspace 'OstSdk.xcworkspace'
    # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
    use_frameworks!

    inherit! :search_paths
    
    # Pods for OstSdkExample
      pod 'CryptoSwift', '0.14.0'
      pod 'Alamofire', '4.8.1'
      pod 'BigInt', '3.1.0'
      pod 'FMDB', '2.7.5'

  end

  pod 'CryptoSwift', '0.14.0'
  pod 'Alamofire', '4.8.1'
  pod 'BigInt', '3.1.0'
  pod 'FMDB', '2.7.5'
end

target 'Demo-App' do
  workspace 'OstSdk.xcworkspace'
  project 'Demo-App/Demo-App.xcodeproj'

  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Demo-App


  pod 'MaterialComponents', :git => 'https://github.com/material-components/material-components-ios', :branch => 'google-io-codelabs-2018'
  pod 'Alamofire', '4.8.1'
  pod 'CryptoSwift', '0.14.0'
  pod 'BigInt', '3.1.0'
  pod 'FMDB', '2.7.5'
  
end


