require './test/test_base'

describe DocumentFile::Collection do
  describe 'when adding documents to the collection' do
    before do
      @collection = DocumentFile::Collection.new
      @document = MyDocument.new(
        TEST_DIR + '/documents/2010-08-08-test-document-file.textile'
      )
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
      attr = :find_by_title
      assert @collection.respond_to?(attr), fail_msg(attr)
    end

    it 'should define find_all_by_attribute finders' do
      @collection << @document
      attr = :find_all_by_status
      assert @collection.respond_to?(attr), fail_msg(attr)
    end

    it 'should define by_attribute finders for Array attributes' do
      @collection << @document
      attr = :by_tags
      assert @collection.respond_to?(attr), fail_msg(attr)
    end

    it 'should define find_all_by_attribute finders for Array attributes' do
      @collection << @document
      attr = :find_all_by_tag
      assert @collection.respond_to?(attr), fail_msg(attr)
    end

    private
    def fail_msg(failed_attribute)
      "collection does not respond to #{failed_attribute}"
    end
  end

  describe 'when creating a collection from an Array' do
    it 'should not accept non-documents' do
      assert_raises ArgumentError do
        DocumentFile::Collection.new ['a string', 'some more']
      end
    end

    it 'should accept documents' do
      document = MyDocument.new(
        TEST_DIR + '/documents/2010-08-08-test-document-file.textile'
      )
      collection = DocumentFile::Collection.new [document]
      assert document, collection.first
    end
  end
end
