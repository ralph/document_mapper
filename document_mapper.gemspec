# frozen_string_literal: true

$LOAD_PATH.unshift 'lib'
require 'document_mapper/version'

Gem::Specification.new do |s|
  s.name              = 'document_mapper'
  s.version           = DocumentMapper::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'DocumentMapper is an object mapper for plain text documents.'
  s.homepage          = 'http://github.com/ralph/document_mapper'
  s.email             = 'ralph@rvdh.de'
  s.authors           = ['Ralph von der Heyden']
  s.required_ruby_version = '>= 2.6.0'

  s.files             = %w[LICENSE README.md]
  s.files            += Dir.glob('lib/**/*')
  s.files            += Dir.glob('test/**/*')

  s.specification_version = 3
  s.add_runtime_dependency('activemodel')
  s.add_runtime_dependency('activesupport')
  s.add_runtime_dependency('rake')
  s.add_runtime_dependency('tilt')
  s.add_development_dependency('minitest')
  s.add_development_dependency('RedCloth')
  s.add_development_dependency('rubocop')

  s.description = <<DESC
  DocumentMapper is an object mapper for plain text documents. The documents look like the ones used in jekyll (http://github.com/mojombo/jekyll). They consist of a preambel written in YAML (also called YAML front matter), and some content in the format you prefer, e.g. Textile. This enables you to write documents in your favorite editor and access the content and metadata of these in your Ruby scripts.
DESC
end
