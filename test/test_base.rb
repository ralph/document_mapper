require 'minitest/spec'
MiniTest::Unit.autorun
require 'set'
require 'fileutils'

lib_dir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'document_file'
TEST_DIR = File.dirname(__FILE__)

class MyDocument
  include DocumentFile
  self.documents_dir = (TEST_DIR + '/documents')
end
