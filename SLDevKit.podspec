#
# Be sure to run `pod lib lint SLDevKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SLDevKit'
  s.version          = '1.0.17'
  s.summary          = 'iOS开发基础库集合.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/sweetloser/SLDevKit.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'sweetloser' => '18272160172@163.com' }
  s.source           = { :git => 'https://github.com/sweetloser/SLDevKit.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'SLDevKit/SLDevKit.h'

  s.subspec "SLDefs" do |sd|
    sd.source_files = 'SLDevKit/SLDefs/*.{h,m}'
  end
  
  s.subspec "SLUtils" do |su|
    su.dependency 'SLDevKit/SLDefs'
    su.source_files = 'SLDevKit/SLUtils/*.{h,m}'
    su.frameworks = 'SystemConfiguration'
  end
  
  s.subspec "SLFoundation" do |sf|
    sf.dependency 'SLDevKit/SLDefs'
    sf.dependency 'SLDevKit/SLUtils'
    sf.source_files = 'SLDevKit/SLFoundation/*.{h,m}'
  end

  s.subspec "SLUIKit" do |suk|
    suk.dependency 'SLDevKit/SLDefs'
    suk.dependency 'SLDevKit/SLUtils'
    suk.dependency 'SLDevKit/SLFoundation'
    
    suk.source_files = 'SLDevKit/SLUIKit/*.{h,m}'
  end
  
  s.subspec "SLAutoLayout" do |sal|
    sal.dependency 'SLDevKit/SLUIKit'
    sal.dependency 'SLDevKit/SLDefs'
    sal.dependency 'SLDevKit/SLFoundation'

    sal.source_files = 'SLDevKit/SLAutoLayout/*.{h,m}'
    
  end
  
  s.subspec "SLCustomField" do |scf|
    scf.dependency 'SLDevKit/SLDefs'
    scf.dependency 'SLDevKit/SLUIKit'
    scf.dependency 'SLDevKit/SLFoundation'
    scf.dependency 'SLDevKit/SLAutoLayout'

    scf.source_files = 'SLDevKit/SLCustomField/*.{h,m}'

  end

  s.subspec "SLUpdateAlert" do |sua|
    sua.dependency 'SLDevKit/SLDefs'
    sua.dependency 'SLDevKit/SLUIKit'
    sua.dependency 'SLDevKit/SLFoundation'
    sua.dependency 'SLDevKit/SLAutoLayout'
    
    sua.source_files = 'SLDevKit/SLUpdateAlert/*.{h,m}'

  end
  
  s.subspec "SLCache" do |scc|
    scc.dependency 'SLDevKit/SLDefs'
    scc.source_files = 'SLDevKit/SLCache/*.{h,m}'
  end
  
  s.subspec "SLHooks" do |shk|
    shk.dependency 'SLDevKit/SLDefs'
    shk.source_files = 'SLDevKit/SLHooks/*.{h,m}'
  end
  
  s.subspec "SLModel" do |smd|
    smd.dependency 'SLDevKit/SLDefs'
    smd.dependency 'SLDevKit/SLCache'
    smd.source_files = 'SLDevKit/SLModel/*.{h,m}'
  end
  
#  s.subspec "SLBackTrace" do |sbt|
#    sbt.dependency 'SLDevKit/SLDefs'
#    sbt.dependency 'SLDevKit/SLFoundation'
#
#    sbt.source_files = 'SLDevKit/SLBackTrace/*.{h,m}'
#
#  end

end
