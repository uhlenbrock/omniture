require 'ftools'
omniture_config = File.dirname(__FILE__) + '/../../../config/omniture.yml'
FileUtils.cp File.dirname(__FILE__) + '/omniture.yml.example', omniture_config unless File.exist?(omniture_config)
puts IO.read(File.join(File.dirname(__FILE__), 'README'))
