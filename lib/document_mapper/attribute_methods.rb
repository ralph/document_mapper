# frozen_string_literal: true

module DocumentMapper
  module AttributeMethods
    module Read
      extend ActiveSupport::Concern

      # included do
      #   # Undefine id so it can be used as an attribute name
      #   undef_method(:id) if method_defined?(:id)
      # end

      module ClassMethods
        def define_read_method(attr_name)
          generated_attribute_methods.redefine_method(attr_name) do
            attributes[attr_name]
          end
        end
      end
    end
  end
end
