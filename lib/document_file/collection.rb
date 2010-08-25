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
          attributes_hash = document.data.merge({'file_name' => document.file_name})
          collection.define_dynamic_finders attributes_hash
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
      attributes_hash.each do |attribute, value|
        define_find_all_by attribute, value
        define_find_by attribute

        define_by_array_attribute(attribute) if value.is_a? Array
      end
    end

    # Defines a by attribute finder for Array attributes, e.g.
    # MyDocument.by_tags
    #   => {
    #        "tag_1" => [document_1, document_3],
    #        "tag_2" => [document_2]
    #      }
    def define_by_array_attribute(array_attribute)
      by_attribute = <<-eos
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
      instance_eval by_attribute
    end

    # Finds documents by a specific Array attribute value , e.g.
    # MyDocument.find_all_by_tag('my_tag') => [document_1, document_2, ...]
    def define_find_all_by(attribute, value)
      if value.is_a? Array
        singular_attribute = ActiveSupport::Inflector.singularize attribute
      else
        singular_attribute = attribute
      end
      find_all_by_attribute = <<-eos
        def find_all_by_#{singular_attribute}(attribute)
          if respond_to? :by_#{attribute}
            by_#{attribute}[attribute]
          else
            documents = select do |document|
              if document.respond_to? :#{attribute}
                document.#{attribute} == attribute
              else
                false
              end
            end
            Collection.new documents
          end
        end
      eos
      instance_eval find_all_by_attribute
    end

    # Defines an attribute finder for one document, e.g.
    # MyDocument.find_by_title('some_title') => some_document
    def define_find_by(attribute)
      find_by_attribute = <<-eos
        def find_by_#{attribute}(attribute)
          documents = find_all_by_#{attribute}(attribute)
          documents.any? ? documents.first : nil
        end
      eos
      instance_eval find_by_attribute
    end
  end
end
