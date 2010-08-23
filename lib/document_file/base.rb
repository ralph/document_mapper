require 'yaml'
require 'active_support/inflector'

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
      @data.each do |attribute_name, value|
        instance_variable_set("@#{attribute_name}", value)
        self.class.instance_eval "attr_reader :#{attribute_name}"

        if value.is_a? Array
          define_by_attribute_finder(attribute_name)
          define_find_all_by_attribute_finder(attribute_name)
        end

        define_attribute_finder(attribute_name)
      end
      @@dynamic_methods_defined = true
    end

    # Defines an attribute finder, e.g.
    # MyDocument.find_by_title('some_title') => some_document
    def define_attribute_finder(attribute_name)
      find_by_attribute_method = <<-eos
        def self.find_by_#{attribute_name}(attribute)
          all.detect do |document|
            if document.respond_to?('#{attribute_name}')
              document.#{attribute_name} == attribute
            else
              false
            end
          end
        end
      eos
      self.class.send(:module_eval, find_by_attribute_method)
    end

    # Defines a by attribute finder for Array attributes, e.g.
    # MyDocument.by_tags
    #   => {
    #        "tag_1" => [document_1, document_3],
    #        "tag_2" => [document_2]
    #      }
    def define_by_attribute_finder(array_attribute)
      by_attribute_method = <<-eos
        def self.by_#{array_attribute}
          documents = self.all
          #{array_attribute}_items = {}
          documents.each do |document|
            document.#{array_attribute}.each do |single_item|
              if #{array_attribute}_items.has_key? single_item
                #{array_attribute}_items[single_item] << document
              else
                #{array_attribute}_items[single_item] = [document]
              end
            end if document.#{array_attribute}
          end
          #{array_attribute}_items
        end
      eos
      self.class.send(:module_eval, by_attribute_method)
    end

    # Finds documents by a specific Array attribute value , e.g.
    # MyDocument.find_all_by_tag('my_tag') => [document_1, document_2, ...]
    def define_find_all_by_attribute_finder(array_attribute)
      singular_array_attribute = ActiveSupport::Inflector.singularize array_attribute
      find_all_by_attribute_method = <<-eos
        def self.find_all_by_#{singular_array_attribute}(singular_array_attribute)
          self.by_#{array_attribute}[singular_array_attribute]
        end
      eos
      self.class.send(:module_eval, find_all_by_attribute_method)
    end

    def self.method_missing(method_name, *args)
      self.all unless @@documents
      respond_to?(method_name) ? self.send(method_name, *args) : super
    end
  end
end
