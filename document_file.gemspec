$:.unshift 'lib'
require 'document_file/version'

Gem::Specification.new do |s|
  s.name              = "document_file"
  s.version           = DocumentFile::VERSION
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = 'Document file is an object mapper for plain text documents.'
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
  Document file is an object mapper for plain text documents. The documents look like the ones used in jekyll (http://github.com/mojombo/jekyll). They consist of a preambel written in YAML (also called YAML front matter), and some content in the format you prefer, e.g. Textile. This enables you to write documents in your favorite editor and access the content and metadata of these in your Ruby scripts.
desc
end
