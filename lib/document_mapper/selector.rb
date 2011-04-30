module DocumentMapper
  class Selector
    attr_reader :attribute, :operator

    def initialize(opts = {})
      unless VALID_OPERATORS.include? opts[:operator]
        raise OperatorNotSupportedError
      end
      @attribute, @operator = opts[:attribute], opts[:operator]
    end
  end
end
