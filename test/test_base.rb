require 'minitest/spec'
MiniTest::Unit.autorun

lib_dir = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'document_mapper'
TEST_DIR = File.dirname(__FILE__)
