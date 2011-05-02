module DocumentMapper
  OPERATOR_MAPPING = {
    'equal'   => :==,
    'gt'      => :>,
    'gte'     => :>=,
    'in'      => :in?,
    'include' => :include?,
    'lt'      => :<,
    'lte'     => :<=
  }

  VALID_OPERATORS = OPERATOR_MAPPING.keys
end
