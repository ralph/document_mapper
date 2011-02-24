require 'minitest/spec'
MiniTest::Unit.autorun
require 'set'
require 'fileutils'

lib_dir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'document_mapper'
TEST_DIR = File.dirname(__FILE__)

class MyDocument
  include DocumentMapper
  self.documents_dir = (TEST_DIR + '/documents')
end
