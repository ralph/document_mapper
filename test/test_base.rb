# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'set'
require 'minitest/autorun'
MiniTest.autorun

lib_dir = File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)
require 'document_mapper'

# Prevent verbose warnings
# $VERBOSE = nil

class MyDocument
  include DocumentMapper::Document
end

class MyOtherDocument
  include DocumentMapper::Document
end

module MiniTest
  module Assertions
    def assert_equal_set(exp, act, msg = nil)
      msg = message(msg) { "Expected #{mu_pp(exp)}, not #{mu_pp(act)}" }
      assert(exp.to_set == act.to_set, msg)
    end
  end
end
