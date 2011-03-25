require './test/test_base'
include DocumentMapper

describe Document do
  before do
    Document.reset
  end

  describe 'loading a document from file' do
    before do
      @file_path = sample_file_path_1
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
      assert_equal File.expand_path(@file_path), @document.file_path
    end
  end

  describe 'getting all Documents' do
    it 'should return all documents' do
      assert_equal [sample_document_1, sample_document_2], Document.all
    end
  end

  describe 'resetting the Document class' do
    it 'should clear all documents' do
      assert_equal [sample_document_1], Document.all
      Document.reset
      assert_equal [], Document.all
    end
  end

  describe 'using where queries' do
    before do
      @document_1 = sample_document_1
      @document_2 = sample_document_2
    end

    it 'should return the right documents' do
      found_document = Document.where(:title => @document_1.title).first
      assert_equal @document_1, found_document
      found_document = Document.where(:title => @document_2.title).first
      assert_equal @document_2, found_document
    end

    it 'should be chainable' do
      document_proxy = Document.where(:title => @document_1.title)
      document_proxy.where(:id => @document_1.id)
      assert_equal @document_1, document_proxy.first
    end
  end

  def sample_file_path_1
    'test/documents/2010-08-08-test-document-file.textile'
  end

  def sample_file_path_2
    'test/documents/2010-08-09-another-test-document.textile'
  end

  def sample_document_1
    Document.from_file(sample_file_path_1)
  end

  def sample_document_2
    Document.from_file(sample_file_path_2)
  end

end
