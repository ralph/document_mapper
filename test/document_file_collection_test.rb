require './test/test_base'

describe DocumentFile::Collection do
  before do
    @collection = DocumentFile::Collection.new
    @document = MyDocument.new(TEST_DIR + '/documents/2010-08-08-test-document-file.textile')
  end

  it 'should not accept non-documents' do
    begin
      @collection << 'some string'
    rescue ArgumentError
      assert true
      return
    end
    assert false, 'collection falsely accepted a non DocumentFile datatype'
  end

  it 'should accept documents' do
    @collection << @document
    assert_equal @document, @collection.first
  end
  
  it 'should define find_by_attribute finders' do
    @collection << @document
    assert @collection.respond_to?(:find_by_title), 'collection does not respond to find_by_title'
  end
  
  it 'should define by_attribute finders for Array attributes' do
    @collection << @document
    assert @collection.respond_to?(:by_tags), 'collection does not respond to by_tags'
  end
  
  it 'should define find_all_by_attribute finders for Array attributes' do
    @collection << @document
    assert @collection.respond_to?(:find_all_by_tag), 'collection does not respond to find_all_by_tag'
  end
end
