Pod::Spec.new do |s|
  s.name         = "WXBMethod"
  s.version      = "1.0.5"
  s.summary      = "微企助基本方法集合"
  s.description  = <<-DESC
                  微企助基本方法集合(包括数据请求,七牛文件上传下载)
                   DESC

  s.homepage     = "https://coding.net/u/mamie/p/WXBMethod"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "mamie" => "mamie42@126.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://git.coding.net/mamie/WXBMethod.git", :tag => "#{s.version}" }
  s.source_files  = "WXBMethod/**/*.{h,m}"
  # s.public_header_files = "WXBMethod/**/*.h"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 3.1.0"
  s.dependency "FMDB","~>2.6"
  s.dependency "Qiniu","~>7.1"

end
