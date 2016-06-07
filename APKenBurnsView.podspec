Pod::Spec.new do |s|
  s.name             = "APKenBurnsView"
  s.version          = "0.1.0"
  s.summary          = "KenBurns effect written in pure Swift with face recognition."
  s.homepage         = "https://github.com/Alterplay/APKenBurnsView"
  s.license          = 'MIT'
  s.author           = { "Nickolay Sheika" => "nickolai.sheika@alterplay.com" }
  s.source           = { :git => "https://github.com/Alterplay/APKenBurnsView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'APKenBurnsView/Classes/**/*'
  s.resource_bundles = {
    'APValidators' => ['APKenBurnsView/Assets/*.png']
  }

end