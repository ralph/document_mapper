module DocumentMapper
  REVERSE_OPERATOR_MAPPING = {
    'equal' => :==,
    'gt'    => :<,
    'gte'   => :<=,
    'in'    => :include?,
    'lt'    => :>,
    'lte'   => :>=
  }

  VALID_OPERATORS = REVERSE_OPERATOR_MAPPING.keys
end
