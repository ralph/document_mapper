require 'minitest/spec'
MiniTest::Unit.autorun
require 'set'
require 'fileutils'
require 'document_file'

lib_dir = File.dirname(File.dirname(__FILE__)) + '/lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
TEST_DIR = File.dirname(__FILE__)
