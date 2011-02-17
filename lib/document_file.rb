require 'active_support/core_ext/class'
require 'active_support/concern.rb'
require 'document_file/collection'
require 'document_file/version'
require 'yaml'

module DocumentFile
  extend ActiveSupport::Concern

  included do
    class_inheritable_accessor :documents_dir
    self.documents_dir = './documents'
  end

  attr_reader :content, :file_path, :data

  def initialize(new_file_path)
    @file_path = if File.exist? new_file_path
                   new_file_path
                 else
                   [self.documents_dir, new_file_path].join('/')
                 end
    read_yaml
  end

  def file_name
    File.basename file_name_with_extension, file_extension
  end

  def file_name_with_extension
    self.file_path.split('/').last
  end

  def file_extension
    File.extname file_name_with_extension
  end

private
  def read_yaml
    @content = File.read(@file_path)

    if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      @content = @content[($1.size + $2.size)..-1]
      @data = YAML.load($1)
    end
    @data ||= {}
    if !@data.has_key? 'date'
      begin
        match = File.basename(@file_path).match(/(\d{4})-(\d{1,2})-(\d{1,2}).*/)
        @data['date'] = Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
      rescue NoMethodError => err
      end
    end
    define_dynamic_methods
  end

  def define_dynamic_methods
    @data.each do |attribute, value|
      attribute_reader = "def #{attribute}; @data['#{attribute}']; end"
      self.class.module_eval attribute_reader
    end
  end

  module ClassMethods
    @@documents = nil

    def all(options = {})
      offset = options[:offset]
      limit = options[:limit]
      return @@documents.offset_and_limitize(offset, limit) if @@documents
      reload!
    end

    def reload!
      if File.directory?(documents_dir)
        file_paths = Dir.glob("#{documents_dir}/*.*")
        @@documents = Collection.new file_paths.map { |fp| self.new fp }
      else
        []
      end
    end

  private
    def method_missing(method_name, *args)
      all.respond_to?(method_name) ? self.all.send(method_name, *args) : super
    end
  end
end

