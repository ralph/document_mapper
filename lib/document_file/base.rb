require 'yaml'

module DocumentFile
  class Base
    @@documents_dir = './documents'
    @@documents = nil
    attr_reader :content, :file_path

    def initialize(new_file_path)
      @file_path = new_file_path
      define_attribute_finder('file_name')
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
        @@documents = file_paths.map { |file_path| self.new file_path }
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
      @data.each do |method_name, value|
        value = "'#{value}'" if value.is_a? String
        instance_eval "def #{method_name}; #{value}; end"

        if value.is_a? Array
          by_attribute_method = <<-eos
            def self.by_#{method_name}
              documents = self.all
              #{method_name} = {}
              documents.each do |document|
                document.#{method_name}.each do |single_item|
                  if #{method_name}.has_key? single_item
                    #{method_name}[single_item] << document
                  else
                    #{method_name}[single_item] = [document]
                  end
                end
              end
              #{method_name}
            end
          eos
          self.class.send(:module_eval, by_attribute_method)
        end

        define_attribute_finder(method_name)
      end
      @@dynamic_methods_defined = true
    end

    def define_attribute_finder(method_name)
      find_by_attribute_method = <<-eos
        def self.find_by_#{method_name}(attribute)
          all.detect {|document| document.#{method_name} == attribute}
        end
      eos
      self.class.send(:module_eval, find_by_attribute_method)
    end

    def self.method_missing(method_name, *args)
      self.all unless @@documents
      super
    end
  end
end
