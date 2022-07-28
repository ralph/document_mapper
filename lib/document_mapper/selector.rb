# frozen_string_literal: true

module DocumentMapper
  class Selector
    attr_reader :attribute, :operator

    def initialize(opts = {})
      raise OperatorNotSupportedError unless VALID_OPERATORS.include? opts[:operator]

      @attribute = opts[:attribute]
      @operator = opts[:operator]
    end
  end
end
