#
# Be sure to run `pod lib lint Component.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
    s.name             = 'Component'
    s.version          = '0.1.1'
    s.summary          = 'Share view component included VM and V'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = 'This is description'
    
    s.homepage         = 'https://github.com/Ponlavit/Component'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Ponlavit' => 'ponlavit.lar@gmail.com' }
    s.source           = { :git => 'https://github.com/Ponlavit/Component.git', :tag => s.version.to_s, :submodules => true }

    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '10.0'
    s.default_subspecs = 'Component'

    s.subspec 'Component' do |component|
        component.source_files = 'Component/Classes/Componets/**/*'
        component.dependency 'RxSwift',    '~> 4.0'
        component.dependency 'RxCocoa',    '~> 4.0'
        component.resource_bundles = {
            'Component' => ['Component/Classes/Componets/**/*/*.xib']
        }
    end
    
    s.subspec 'Drawer' do |drawer|
        drawer.source_files = 'Component/Classes/Drawer/*.swift'
        drawer.dependency 'KWDrawerController'
        drawer.dependency 'KWDrawerController/RxSwift'
        drawer.resource_bundles = {
            'Drawer' => ['Component/Classes/Drawer/**/*/*.xib']
        }
    end
    
    s.dependency 'Base'
    
    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    
    
    
    
end

