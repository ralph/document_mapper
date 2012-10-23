$:.unshift 'lib'
require 'document_mapper/version'

Gem::Specification.new do |s|
  s.name              = 'document_mapper'
  s.version           = DocumentMapper::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'DocumentMapper is an object mapper for plain text documents.'
  s.homepage          = 'http://github.com/ralph/document_mapper'
  s.email             = 'ralph@rvdh.de'
  s.authors           = [ 'Ralph von der Heyden' ]

  s.files             = %w( LICENSE README.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.specification_version = 3
  s.add_runtime_dependency('activesupport', '~> 3.1')
  s.add_runtime_dependency('activemodel', '~> 3.1')
  s.add_runtime_dependency('rake', '~> 0.9.0')
  s.add_runtime_dependency('tilt', '~> 1.3.0')
  s.add_development_dependency('RedCloth', '~> 4.2.0')
  s.add_development_dependency('minitest', '~> 2.6.0')

  s.description       = <<desc
  DocumentMapper is an object mapper for plain text documents. The documents look like the ones used in jekyll (http://github.com/mojombo/jekyll). They consist of a preambel written in YAML (also called YAML front matter), and some content in the format you prefer, e.g. Textile. This enables you to write documents in your favorite editor and access the content and metadata of these in your Ruby scripts.
desc
end
