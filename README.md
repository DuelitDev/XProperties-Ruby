# XProperties
XProperties is a .properties file parser library, which was written to read/write .properties files in languages other than Java.  
## Install
`gem install XProperties`  
## Documentation
[XProperties Wiki](https://github.com/DuelitDev/XProperties-Ruby/wiki)  
## Example
```ruby
# example.rb
require 'XProperties'


prop = Properties.new
prop.load "example.properties"
puts prop["example"]
```  
## Copyright
Copyright 2023. DuelitDev all rights reserved.  
## License
[LGPL-2.1 License](https://github.com/DuelitDev/XProperties/blob/master/LICENSE)  
