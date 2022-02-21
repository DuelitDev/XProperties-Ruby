Gem::Specification.new do |s|
  s.name        = "XProperties"
  s.version     = "2.0.10"
  s.date        = "2022-02-21"
  s.summary     = ".properties file parser"
  s.description = "Cross-Language .properties file parser"
  s.authors     = ["DuelitDev"]
  s.email       = "jyoon07dev@gmail.com"
  s.files       = %w[setup.gemspec lib/xproperties.rb lib/xproperties/properties.rb]
  s.homepage    = "https://github.com/Duelit/XProperties"
  s.license     = "LGPL-2.1"
  s.required_ruby_version = Gem::Requirement.new(">= 2.6")
end


# gem build setup.gemspec
# gem push XProperties-x.x.x.gem
