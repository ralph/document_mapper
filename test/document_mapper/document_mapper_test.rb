# frozen_string_literal: true

require 'test_base'
include DocumentMapper

describe MyDocument do
  before do
    MyDocument.reset
  end

  describe 'loading a document from file' do
    before do
      @file_path = sample_file_path_1
      @document = MyDocument.from_file(@file_path)
    end

    it 'should load the document from a yaml file' do
      assert_equal 1, @document.attributes[:id]
      assert_equal 'Some fancy title', @document.attributes[:title]
      assert_equal ['ruby'], @document.attributes[:tags]
      assert_equal :published, @document.attributes[:status]
    end

    it 'should specify attributes from the YAML header' do
      assert_equal 1, @document.id
      assert_equal 'Some fancy title', @document.title
      assert_equal ['ruby'], @document.tags
      assert_equal :published, @document.status
    end

    it 'should return the file path' do
      assert_equal File.expand_path(@file_path), @document.file_path
    end

    it 'should return the file name' do
      expected_name = '2010-08-08-test-document-file.textile'
      assert_equal expected_name, @document.file_name
    end

    it 'should return the file name without extension' do
      expected_name = '2010-08-08-test-document-file'
      assert_equal expected_name, @document.file_name_without_extension
    end

    it 'should return the extension' do
      assert_equal 'textile', @document.extension
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
        assert_equal nil, @document.year
        assert_equal nil, @document.month
        assert_equal nil, @document.day
      end
    end

    describe 'loading a documents directory' do
      it 'should load all the documents in that directory' do
        MyDocument.directory = 'test/documents'
        assert_equal_set [1, 2, 3, 4], MyDocument.all.map(&:id)
      end

      it 'should ignore all dotfile' do
        MyDocument.directory = 'test/documents'
        refute MyDocument.all.map(&:id).include?(5)
      end
    end
  end

  describe 'getting all/the first/the last MyDocument(s)' do
    before do
      @all_documents = [sample_document_1, sample_document_2]
    end

    it 'should return all documents' do
      assert_equal @all_documents, MyDocument.all
    end

    it 'should return the first document' do
      assert_equal @all_documents.first, MyDocument.first
    end

    it 'should return the last document' do
      assert_equal @all_documents.last, MyDocument.last
    end
  end

  describe 'using offset and limit' do
    before do
      MyDocument.directory = 'test/documents'
    end

    it 'should limit the documents to the number specified' do
      assert_equal_set [1, 2], MyDocument.order_by(:id).limit(2).all.map(&:id)
    end

    it 'should offset the documents by the number specified' do
      assert_equal_set [3, 4], MyDocument.order_by(:id).offset(2).all.map(&:id)
    end

    it 'should support offset and limit at the same time' do
      assert_equal_set [2, 3], MyDocument.order_by(:id).offset(1).limit(2).all.map(&:id)
    end

    it 'should not freak out about an offset higher than the document count' do
      assert_equal_set [], MyDocument.order_by(:id).offset(5).all
    end
  end

  describe 'resetting the MyDocument class' do
    it 'should clear all documents' do
      one_document = sample_document_1
      assert_equal [one_document], MyDocument.all
      MyDocument.reset
      assert_equal [], MyDocument.all
    end
  end

  describe 'using where queries' do
    before do
      @document_1 = sample_document_1
      @document_2 = sample_document_2
      MyDocument.directory = 'test/documents'
    end

    describe 'with an equal operator' do
      it 'should return the right documents' do
        found_document = MyDocument.where(title: @document_1.title).first
        assert_equal @document_1, found_document
        found_document = MyDocument.where(title: @document_2.title).first
        assert_equal @document_2, found_document
      end

      it 'should be chainable' do
        document_proxy = MyDocument.where(title: @document_1.title)
        document_proxy.where(id: @document_1.id)
        assert_equal @document_1, document_proxy.first
      end

      it 'should work with file names without extensions' do
        file_name = '2010-08-08-test-document-file'
        selector_hash = { file_name_without_extension: file_name }
        found_document = MyDocument.where(selector_hash).first
        assert_equal sample_document_1, found_document
      end

      it 'should work with file names' do
        file_name = '2010-08-08-test-document-file.textile'
        found_document = MyDocument.where(file_name: file_name).first
        assert_equal sample_document_1, found_document
      end

      it 'should work with dates' do
        found_documents = MyDocument.where(year: 2010).all
        expected_documents = [sample_document_1, sample_document_2]
        assert_equal_set expected_documents.map(&:id), found_documents.map(&:id)
      end

      it 'should not be confused by attributes not present in all documents' do
        MyDocument.directory = 'test/documents'
        result = MyDocument.where(seldom_attribute: 'is seldom').all
        assert_equal_set [4], result.map(&:id)
      end
    end

    describe 'with a gt operator' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'gt'
        found_documents = MyDocument.where(selector => 2).all
        assert_equal_set [3, 4], found_documents.map(&:id)
      end
    end

    describe 'with a gte operator' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'gte'
        found_documents = MyDocument.where(selector => 2).all
        assert_equal_set [2, 3, 4], found_documents.map(&:id)
      end
    end

    describe 'with an in operator' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'in'
        found_documents = MyDocument.where(selector => [2, 3]).all
        assert_equal_set [2, 3], found_documents.map(&:id)
      end
    end

    describe 'with an lt operator' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'lt'
        found_documents = MyDocument.where(selector => 2).all
        assert_equal_set [1], found_documents.map(&:id)
      end
    end

    describe 'with an lte operator' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'lte'
        found_documents = MyDocument.where(selector => 2).all
        assert_equal_set [1, 2], found_documents.map(&:id)
      end
    end

    describe 'with an include operator' do
      it 'include should return the right documents' do
        selector = Selector.new attribute: :tags, operator: 'include'
        found_documents = MyDocument.where(selector => 'ruby').all
        assert_equal_set [1, 2], found_documents.map(&:id)
      end
    end

    describe 'with mixed operators' do
      it 'should return the right documents' do
        in_selector = Selector.new attribute: :id, operator: 'in'
        gt_selector = Selector.new attribute: :id, operator: 'gt'
        documents_proxy = MyDocument.where(in_selector => [2, 3])
        found_documents = documents_proxy.where(gt_selector => 2).all
        assert_equal_set [3], found_documents.map(&:id)
      end
    end

    describe 'using multiple constrains in one where' do
      it 'should return the right documents' do
        selector = Selector.new attribute: :id, operator: 'lte'
        found_documents = MyDocument.where(selector => 2, :status => :published).all
        assert_equal_set [1, 2], found_documents.map(&:id)
      end
    end
  end

  describe 'sorting the documents' do
    before do
      MyDocument.directory = 'test/documents'
    end

    it 'should support ordering by attribute ascending' do
      found_documents = MyDocument.order_by(title: :asc).all
      assert_equal [2, 3, 1, 4], found_documents.map(&:id)
    end

    it 'should support ordering by attribute descending' do
      found_documents = MyDocument.order_by(title: :desc).all
      assert_equal [4, 1, 3, 2], found_documents.map(&:id)
    end

    it 'should order by attribute ascending by default' do
      found_documents = MyDocument.order_by(:title).all
      assert_equal [2, 3, 1, 4], found_documents.map(&:id)
    end

    it 'should exclude documents that do not own the attribute' do
      found_documents = MyDocument.order_by(:status).all
      assert_equal [1, 2].to_set, found_documents.map(&:id).to_set
    end
  end

  describe 'reloading the Document class' do
    it 'should discover new documents' do
      @file_path = 'test/documents/2011-04-26-new-stuff.textile'
      File.open(@file_path, 'w') do |f|
        f.write <<~DOCUMENT
          ---
          id: 5
          title: Some brand new document
          ---

          Very new stuff.
        DOCUMENT
      end
      MyDocument.reload
      assert_equal [1, 2, 3, 4, 5].sort, MyDocument.all.map(&:id).sort
    end

    def teardown
      File.delete @file_path
    end
  end

  describe 'getting a list of all the attributes' do
    before do
      MyDocument.directory = 'test/documents'
    end

    it 'should return an ordered list of all the attributes' do
      expected_attributes = %w[
        date
        day
        extension
        file_name
        file_name_without_extension
        file_path
        friends
        id
        month
        seldom_attribute
        special_attribute
        status
        tags
        title
        year
      ].map(&:to_sym)
      assert_equal expected_attributes, MyDocument.attributes
    end
  end

  describe 'rendering the document as html' do
    before do
      @file_path = sample_file_path_1
      @document = MyDocument.from_file(@file_path)
    end

    it 'should render the content as html' do
      assert_equal '<p>I like being the demo text.</p>', @document.to_html
    end
  end

  describe 'loading a document with invalid yaml' do
    it 'should raise with a decent error message' do
      @file_path = File.expand_path('test/documents/invalid_yaml.textile')
      File.open(@file_path, 'w') do |f|
        f.write <<~DOCUMENT
          ---
          title: Look: Invalid YAML!
          ---

          This is definitely gonna blow up.
        DOCUMENT
      end
      proc { MyDocument.reload }.must_raise(DocumentMapper::YamlParsingError, "Unable to parse YAML of #{@file_path}")
    end

    def teardown
      File.delete @file_path
    end
  end

  describe 'multiple document classes' do
    it 'can serve multiple document directories' do
      MyDocument.directory = 'test/documents'
      MyOtherDocument.directory = 'test/other_documents'

      assert_equal 4, MyDocument.all.count
      assert_equal 1, MyOtherDocument.all.count
    end
  end

  def sample_file_path_1
    'test/documents/2010-08-08-test-document-file.textile'
  end

  def sample_file_path_2
    'test/documents/2010-08-09-another-test-document.textile'
  end

  def sample_document_1
    MyDocument.from_file(sample_file_path_1)
  end

  def sample_document_2
    MyDocument.from_file(sample_file_path_2)
  end

  def sample_document_with_date_in_yaml
    file_path = 'test/documents/document_with_date_in_yaml.textile'
    MyDocument.from_file(file_path)
  end

  def sample_document_without_date
    file_path = 'test/documents/document_without_date.textile'
    MyDocument.from_file(file_path)
  end
end
