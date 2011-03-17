require 'minitest/spec'
MiniTest::Unit.autorun
require 'set'
require 'fileutils'

lib_dir = File.dirname(__FILE__) + '/lib'
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'document_mapper'
TEST_DIR = File.dirname(__FILE__)
