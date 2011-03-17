require './test/test_base'
include DocumentMapper

describe Document do
  describe 'loading a document from file' do
    before do
      file_name = 'test/documents/2010-08-08-test-document-file.textile'
      @document = Document.from_file(file_name)
    end

    it 'should load the document from a yaml file' do
      assert_equal 1, @document.data['id']
      assert_equal 'Some fancy title', @document.data['title']
      assert_equal ['ruby'], @document.data['tags']
      assert_equal :published, @document.data['status']
    end
  end

  describe 'using where queries' do
    before do
      file_name = 'test/documents/2010-08-08-test-document-file.textile'
      @document = Document.from_file(file_name)
    end

    # it 'should return the right documents' do
    #   found_documents = Document.where(:title => @document.data['title']).first
    #   assert_equal @document, found_documents
    # end
  end
end
