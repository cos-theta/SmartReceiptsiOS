platform :ios, '8.0'

use_frameworks!

project 'SmartReceipts.xcodeproj'

def pods
    pod 'Tweaks', '~> 2.0.0'
    pod 'UIAlertView-Blocks', '~> 1.0'
    pod 'objective-zip', '1.0.2', :inhibit_warnings => true
    pod 'CMPopTipView', '2.3.0'
    pod 'FMDB', '2.6.2'
    pod 'HTAutocompleteTextField', '1.3.2'
    pod 'Google-Mobile-Ads-SDK'
    pod 'MRProgress', '0.8.3'
    pod 'Google/Analytics'
    pod 'SplunkMint'
    pod 'RMStore/Core', :path => '3rdparty/RMStore'
    pod 'RMStore/KeychainPersistence', :path => '3rdparty/RMStore'
    pod 'RMStore/AppReceiptVerificator', :path => '3rdparty/RMStore'
end

target 'SmartReceipts' do
    pods
end

target 'SmartReceiptsTests' do
    pods
end
