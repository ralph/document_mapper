require './test/test_base'
include DocumentMapper

describe Selector do
  it 'should initialize with an attribute and an operator' do
    selector = Selector.new :attribute => 'author', :operator => 'equal'
    assert_equal 'author', selector.attribute
    assert_equal 'equal', selector.operator
  end

  it 'should raise an exception if the operator is not supported' do
    assert_raises OperatorNotSupportedError do
      selector = Selector.new :attribute => 'author', :operator => 'zomg'
    end
  end
end
