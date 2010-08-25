require 'active_support/inflector'

module DocumentFile
  class Collection < Array
    def <<(document)
      self.class.ensure_document(document)
      define_dynamic_finders document.data
      super
    end

    class << self
      def new_with_finders(*args)
        collection = new_without_finders(*args)
        collection.each do |document|
          self.ensure_document(document)
          collection.define_dynamic_finders document.data
        end
        collection
      end

      alias_method :new_without_finders, :new
      alias_method :new, :new_with_finders
    end

    def self.ensure_document(document)
      raise ArgumentError unless document.is_a? DocumentFile::Base
    end

    def define_dynamic_finders(attributes_hash)
      define_attribute_finder 'file_name'
      attributes_hash.each do |attribute, value|
        define_attribute_finder attribute

        if value.is_a? Array
          define_by_attribute_finder(attribute)
          define_find_all_by_attribute_finder(attribute)
        end
      end
    end

    # Defines a by attribute finder for Array attributes, e.g.
    # MyDocument.by_tags
    #   => {
    #        "tag_1" => [document_1, document_3],
    #        "tag_2" => [document_2]
    #      }
    def define_by_attribute_finder(array_attribute)
      by_attribute_method = <<-eos
        def by_#{array_attribute}
          #{array_attribute}_items = {}
          each do |document|
            document.#{array_attribute}.each do |single_item|
              if #{array_attribute}_items.has_key? single_item
                #{array_attribute}_items[single_item] << document
              else
                #{array_attribute}_items[single_item] = Collection.new [document]
              end
            end if document.#{array_attribute}
          end
          #{array_attribute}_items
        end
      eos
      instance_eval by_attribute_method
    end

    # Finds documents by a specific Array attribute value , e.g.
    # MyDocument.find_all_by_tag('my_tag') => [document_1, document_2, ...]
    def define_find_all_by_attribute_finder(array_attribute)
      singular_array_attribute = ActiveSupport::Inflector.singularize array_attribute
      find_all_by_attribute_method = <<-eos
        def find_all_by_#{singular_array_attribute}(singular_array_attribute)
          by_#{array_attribute}[singular_array_attribute]
        end
      eos
      instance_eval find_all_by_attribute_method
    end

    # Defines an attribute finder, e.g.
    # MyDocument.find_by_title('some_title') => some_document
    def define_attribute_finder(attribute_name)
      find_by_attribute_method = <<-eos
        def find_by_#{attribute_name}(attribute)
          detect do |document|
            if document.respond_to?('#{attribute_name}')
              document.#{attribute_name} == attribute
            else
              false
            end
          end
        end
      eos
      instance_eval find_by_attribute_method
    end
  end
end
