Gem::Specification.new do |s|
  s.name        = "XProperties"
  s.version     = "1.1.6"
  s.date        = "2022-02-14"
  s.summary     = ".properties file parser"
  s.description = "Cross-Language .properties file parser"
  s.authors     = ["Duelit"]
  s.email       = "jyoon07dev@gmail.com"
  s.files       = %w[setup.gemspec lib/xproperties.rb]
  s.homepage    = "https://github.com/Duelit/XProperties"
  s.license     = "LGPL-2.1"
  s.required_ruby_version = Gem::Requirement.new(">= 2.6")
end


# gem build setup.gemspec
# gem push XProperties-x.x.x.gem
