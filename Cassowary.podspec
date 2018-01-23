
Pod::Spec.new do |s|
  s.name         = "Cassowary"
  s.version      = "1.0.0"
  s.summary      = "A Swift port of the Cassowary linear constraint solver"
  s.description  = <<-DESC
  A library that implements the Cassowary linear constraint solving algorithm in pure Swift
                   DESC
                   
  s.homepage     = "https://github.com/tribalworldwidelondon/CassowarySwift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author    = "Tribal Worldwide London"
  s.source       = { :git => "https://github.com/tribalworldwidelondon/CassowarySwift.git", :tag => "1.0.0" }
  s.source_files  = "Sources/**/*.{swift}"
  s.ios.deployment_target = '8.0'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'Tests/**/*.{swift}'
  end

end
