require './test/test_base'

describe DocumentFile::Collection do
  describe 'when adding documents to the collection' do
    before do
      @collection = DocumentFile::Collection.new
      @document = MyDocument.new('2010-08-08-test-document-file.textile')
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
      document = MyDocument.new '2010-08-08-test-document-file.textile'
      collection = DocumentFile::Collection.new [document]
      assert document, collection.first
    end
  end

  describe 'when finding documents by date' do
    it 'should return a collection' do
      documents = MyDocument.find_all_by_date 2010
      assert_equal documents.class, DocumentFile::Collection
    end

    it 'should return all documents with the year specified' do
      documents = MyDocument.find_all_by_date 2010
      assert_equal 2, documents.size
    end

    it 'should return all documents with the year and month specified' do
      documents = MyDocument.find_all_by_date 2010, 8
      assert_equal 2, documents.size
    end

    it 'should return all documents with the year, month and day specified' do
      documents = MyDocument.find_all_by_date 2010, 8, 8
      assert_equal 1, documents.size
    end

    it 'should return the first match' do
      document = MyDocument.find_by_date 2010, 8
      assert_equal 1, document.id
    end
  end
end
