Pod::Spec.new do |s|
  s.name         = "WXBMethod"
  s.version      = "1.0.5"
  s.ios.deployment_target = '8.0'
  s.summary      = "微企助基本方法集合"
  s.description  ="基本方法集合(包括数据请求,七牛文件上传下载)"

  s.homepage     = "https://github.com/mamie42/WXBMethod"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "mamie" => "mamie42@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => " https://github.com/mamie42/WXBMethod.git", :tag => "#{s.version}" }
  s.source_files  = "WXBMethod/**/*.{h,m}"
  # s.public_header_files = "WXBMethod/**/*.h"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.1.0"
  s.dependency "FMDB","~>2.6"
  s.dependency "Qiniu","~>7.1"

end
