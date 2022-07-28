# frozen_string_literal: true

module DocumentMapper
  OPERATOR_MAPPING = {
    'equal' => :==,
    'gt' => :>,
    'gte' => :>=,
    'in' => :in?,
    'include' => :include?,
    'lt' => :<,
    'lte' => :<=
  }.freeze

  VALID_OPERATORS = OPERATOR_MAPPING.keys
end
