require './test/test_base'
include DocumentMapper

describe Document do
  describe 'loading a document from file' do
    before do
      @file_path = 'test/documents/2010-08-08-test-document-file.textile'
      @document = Document.from_file(@file_path)
    end

    it 'should load the document from a yaml file' do
      assert_equal 1, @document.attributes['id']
      assert_equal 'Some fancy title', @document.attributes['title']
      assert_equal ['ruby'], @document.attributes['tags']
      assert_equal :published, @document.attributes['status']
    end

    it 'should specify attributes from the YAML header' do
      assert_equal 1, @document.id
      assert_equal 'Some fancy title', @document.title
      assert_equal ['ruby'], @document.tags
      assert_equal :published, @document.status
      assert_equal '2010-08-08', @document.date.to_s
      assert_equal @file_path, @document.file_path
    end
  end

  describe 'using where queries' do
    before do
      file_name = 'test/documents/2010-08-08-test-document-file.textile'
      @document = Document.from_file(file_name)
    end

    # it 'should return the right documents' do
    #   found_documents = Document.where(:title => @document.attributes['title']).first
    #   assert_equal @document, found_documents
    # end
  end
end
