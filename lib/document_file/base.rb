require 'yaml'

module DocumentFile
  class Base
    @@documents_dir = './documents'
    @@documents = nil
    attr_reader :content, :file_path, :data

    def initialize(new_file_path)
      @file_path = new_file_path
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

    def self.all
      return @@documents if @@documents
      self.reload!
    end

    def self.reload!
      if File.directory?(@@documents_dir)
        file_paths = Dir.glob("#{@@documents_dir}/*.*")
        @@documents = Collection.new file_paths.map { |file_path| self.new file_path }
      else
        []
      end
    end

    def self.documents_dir
      @@documents_dir
    end

    def self.documents_dir=(new_dir)
      @@documents_dir = new_dir
    end

  private
    def read_yaml
      @content = File.read(@file_path)

      if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @content = @content[($1.size + $2.size)..-1]
        @data = YAML.load($1)
      end
      @data ||= {}
      define_dynamic_methods
    end

    def define_dynamic_methods
      @data.each do |attribute_name, value|
        attribute_reader = "def #{attribute_name}; @data['#{attribute_name}']; end"
        self.class.module_eval attribute_reader
      end
      @@dynamic_methods_defined = true
    end

    def self.method_missing(method_name, *args)
      self.all unless @@documents
      self.all.respond_to?(method_name) ? self.all.send(method_name, *args) : super
    end
  end
end
