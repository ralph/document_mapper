module DocumentMapper
  module AttributeMethods
    module Read
      extend ActiveSupport::Concern

      included do
        # Undefine id so it can be used as an attribute name
        undef_method(:id) if method_defined?(:id)
      end

      module ClassMethods
        def define_read_method(attr_name)
          access_code = "attributes['#{attr_name}']"
          generated_attribute_methods.module_eval("def #{attr_name}; #{access_code}; end", __FILE__, __LINE__)

          %w(year month day).each do |attr_name|
            access_code = "date.#{attr_name} if date"
            generated_attribute_methods.module_eval("def #{attr_name}; #{access_code}; end", __FILE__, __LINE__)
          end

        end
      end
    end
  end
end
