$:.unshift 'lib'
require 'document_file/version'

Gem::Specification.new do |s|
  s.name              = "document_file"
  s.version           = DocumentFile::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'Write documents in your fav editor. Read them in your Ruby app.'
  s.homepage          = 'http://github.com/ralph/document_file'
  s.email             = 'ralph@rvdh.de'
  s.authors           = [ 'Ralph von der Heyden' ]
  s.has_rdoc          = false

  s.files             = %w( LICENSE README.textile )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.specification_version = 3
  s.add_runtime_dependency('activesupport', '~> 3.0.0')

  s.description       = <<desc
  Makes your plain text files accessible in Ruby. Supports YAML front matter.
desc
end
