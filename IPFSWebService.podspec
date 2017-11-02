Pod::Spec.new do |s|
  s.name        = 'IPFSWebService'
  s.version     = '0.0.1'
  s.summary     = 'Defines and versions the HTTP based IPFS interface.'
  s.description = <<-DESC
  The API for communication with an IPFS server is defined and versioned by
  this [Swagger Specification](https://swagger.io).

  iOS clients need only include this API as a cocoapod dependency.
                  DESC

  s.homepage  = "https://github.com/connorpower/IPFSWebService"
  s.source    = { :git => 'git@github.com:connorpower/IPFSWebService.git', :tag => s.version.to_s }
  s.authors   = 'Connor Power'
  s.license   = 'Proprietary'

  s.source_files = 'SwaggerClient/Classes/Swaggers/**/*.swift'
  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.dependency 'Alamofire', '~> 4.5'
end
