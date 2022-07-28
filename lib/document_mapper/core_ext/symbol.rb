# frozen_string_literal: true

class Symbol
  DocumentMapper::VALID_OPERATORS.each do |operator|
    class_eval <<-OPERATORS, __FILE__, __LINE__ + 1
      def #{operator}
        DocumentMapper::Selector.new(:attribute => self, :operator => '#{operator}')
      end
    OPERATORS
  end

  unless method_defined?(:"<=>")
    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
