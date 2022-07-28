# frozen_string_literal: true

require 'test_base'
include DocumentMapper

describe Symbol do
  it 'should create a selector from a valid operator' do
    selector = :my_attribute.gte
    assert_equal 'gte', selector.operator
    assert_equal :my_attribute, selector.attribute
  end

  it 'should not raise an error on valid operators' do
    :my_attribute.equal
    :my_attribute.gt
    :my_attribute.gte
    :my_attribute.in
    :my_attribute.lt
    :my_attribute.lte
  rescue StandardError
    assert false, 'Calling operator on symbol raised error'
  end

  it 'should raise an error on invalid operators' do
    assert_raises NoMethodError do
      :my_attribute.not_supported
    end
  end
end
