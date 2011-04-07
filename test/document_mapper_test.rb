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
      assert_equal File.expand_path(@file_path), @document.file_path
    end

    describe 'specifying the date of the document' do
      it 'should get the date from the filename' do
        assert_equal '2010-08-08', @document.date.to_s
        assert_equal 2010, @document.date.year
        assert_equal 8, @document.date.month
        assert_equal 8, @document.date.day
      end

      it 'should delegate the day method to date' do
        assert_equal 2010, @document.year
        assert_equal 8, @document.month
        assert_equal 8, @document.day
      end

      it 'should get the date from the yaml front matter if there is one' do
        @document = sample_document_with_date_in_yaml
        assert_equal 2011, @document.year
        assert_equal 4, @document.month
        assert_equal 5, @document.day
      end

      it 'should not freak out if there is no date' do
        @document = sample_document_without_date
        assert_equal nil, @document.date
      end
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

    it 'should work with dates' do
      found_documents = Document.where(:year => 2010).all
      expected_documents = [sample_document_1, sample_document_2]
      assert_equal expected_documents.map(&:id), found_documents.map(&:id)
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

  def sample_document_with_date_in_yaml
    file_path = 'test/documents/document_with_date_in_yaml.textile'
    Document.from_file(file_path)
  end

  def sample_document_without_date
    file_path = 'test/documents/document_without_date.textile'
    Document.from_file(file_path)
  end
end
