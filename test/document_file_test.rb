require './test/test_base'

class MyDocument < DocumentFile::Base
end

describe MyDocument do
  before do
    MyDocument.documents_dir = TEST_DIR + '/documents'
  end

  describe 'when finding all document_files' do
    before do
      @document_files = MyDocument.all
    end

    it 'should return an Array' do
      assert_equal Array, @document_files.class
    end
  
    it "should find all document_files" do
      assert_equal 2, @document_files.size
    end
  end

  describe 'when initializing a MyDocument' do
    before do
      @document_file = MyDocument.new(TEST_DIR + '/documents/2010-08-08-test-document-file.textile')
    end

    it 'should initialize the content' do
      assert_equal "I like the flowers.\n", @document_file.content
    end

    it 'should intitialize strings from the front matter' do
      assert_equal String, @document_file.title.class
      assert_equal 'The shizzle!', @document_file.title
    end

    it 'should intitialize strings from the front matter' do
      assert_equal Array, @document_file.tags.class
      assert_equal ['tag'], @document_file.tags
    end

    it 'should intitialize integers from the front matter' do
      assert_equal Fixnum, @document_file.number_of_foos.class
      assert_equal 42, @document_file.number_of_foos
    end
  end

  describe 'when listing document_files by an Array attribute' do
    it 'should return a Hash' do
      assert_equal Hash, MyDocument.by_tags.class
    end

    it 'should use the tags as Hash keys' do
      assert_equal Set.new(['tag', 'tug']), MyDocument.by_tags.keys.to_set
    end

    it 'should use the document_files as Hash values' do
      document_files = MyDocument.by_tags
      assert_equal Set.new([1, 2]), document_files['tag'].map(&:id).to_set
      assert_equal Set.new([2]), document_files['tug'].map(&:id).to_set
    end

    it 'should not be confused by attributes that only some documents have' do
      document_files_by_authors = MyDocument.by_authors
      assert_equal 1, document_files_by_authors['Frank'].first.id

      document_files_by_friends = MyDocument.by_friends
      assert_equal 2, document_files_by_friends['Anton'].first.id
    end
  end

  describe 'when finding document_files by an Array attribute value' do
    it 'should return an Array' do
      assert_equal Array, MyDocument.find_all_by_tag('tag').class
    end

    it 'should containt documents' do
      assert_equal MyDocument, MyDocument.find_all_by_tag('tag').first.class
    end

    it 'should return the right documents' do
      assert_equal [1, 2], MyDocument.find_all_by_tag('tag').map(&:id)
      assert_equal [2], MyDocument.find_all_by_tag('tug').map(&:id)
    end
  end

  describe 'when finding a document_file' do
    it 'should find the right document_file by an attribute' do
      title = 'The shizzle!'
      document_file = MyDocument.find_by_title(title)
      assert_equal title, document_file.title
    end

    it 'should find the right document_file by file_name' do
      file_name = '2010-08-08-test-document-file'
      document_file = MyDocument.find_by_file_name file_name
      assert_equal document_file.file_name, file_name
    end

    it 'should not be confused by attributes that only some dcuments have' do
      document_file = MyDocument.find_by_special_attribute 'Yes!'
      assert_equal 'Yes!', document_file.special_attribute
    end
  end

  describe 'when getting the file name or file path' do
    it 'should show the right file name' do
      document_file = MyDocument.new './test/documents/2010-08-08-test-document-file.textile'
      file_name = '2010-08-08-test-document-file'
      assert_equal file_name, document_file.file_name
    end

    it 'should show the right file name with extension' do
      document_file = MyDocument.new './test/documents/2010-08-08-test-document-file.textile'
      file_name = '2010-08-08-test-document-file.textile'
      assert_equal file_name, document_file.file_name_with_extension
    end

    it 'should show the right extension' do
      document_file = MyDocument.new './test/documents/2010-08-08-test-document-file.textile'
      extension = '.textile'
      assert_equal extension, document_file.file_extension
    end

    it 'should show the right file path' do
      file_path = './test/documents/2010-08-08-test-document-file.textile'
      document_file = MyDocument.new file_path
      assert_equal file_path, document_file.file_path
    end
  end

  describe 'when calling a method that was not defined dynamically' do
    it 'should throw an error on the class level' do
      assert_raises(NoMethodError) { MyDocument.hululu }
    end

    it 'should throw an error on the instance level' do
      document_file = MyDocument.new('./test/documents/2010-08-08-test-document-file.textile')
      assert_raises(NoMethodError) { document_file.hululu }
    end
  end

  describe 'when reloading all document_files' do
    before do
      @default_dir = TEST_DIR + '/documents'
      MyDocument.documents_dir = @default_dir
      MyDocument.reload!
      @document_files_before = MyDocument.all
      @tmp_dir = "#{@default_dir}-#{Time.now.to_i}-#{rand(999999)}-test"
      FileUtils.cp_r @default_dir, @tmp_dir
    end

    after do
      FileUtils.rm_r(@tmp_dir) if Dir.exist?(@tmp_dir)
    end

    it 'should get updated document_files' do
      updated_document_file = <<-eos
---
id: 1
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the foos.
eos
      document_file_file_name = "#{@tmp_dir}/2010-08-08-test-document-file.textile"
      File.open(document_file_file_name, 'w') {|f| f.write(updated_document_file) }
      MyDocument.documents_dir = @tmp_dir
      MyDocument.reload!
      document_files_after = MyDocument.all

      assert_equal @document_files_before.first.id, document_files_after.first.id
      refute_equal @document_files_before.first.title, document_files_after.first.title
      refute_equal @document_files_before.first.tags, document_files_after.first.tags
      refute_equal @document_files_before.first.number_of_foos, document_files_after.first.number_of_foos
      refute_equal @document_files_before.first.content, document_files_after.first.content
    end

    it 'should get new document_files' do
      new_document_file = <<-eos
---
id: 3
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the cows.
eos
      document_file_file_name = "#{@tmp_dir}/2010-08-15-new-test-document_file.textile"
      File.open(document_file_file_name, 'w') {|f| f.write(new_document_file) }
      MyDocument.documents_dir = @tmp_dir
      MyDocument.reload!
      document_files_after = MyDocument.all

      assert_equal @document_files_before.size + 1, document_files_after.size
      assert_equal 'The shuzzle!', document_files_after.last.title
      assert_equal "I like the cows.\n", document_files_after.last.content
    end

    it 'should not change if no document_files were changed' do
      MyDocument.reload!
      document_files_after = MyDocument.all
      assert_equal @document_files_before.map(&:id), document_files_after.map(&:id)
    end

    it 'should not show deleted document_files' do
      document_file_file_name = "#{@tmp_dir}/2010-08-08-test-document-file.textile"
      FileUtils.rm document_file_file_name
      MyDocument.documents_dir = @tmp_dir
      MyDocument.reload!
      document_files_after = MyDocument.all
      refute_equal @document_files_before.map(&:id), document_files_after.map(&:id)
    end
  end
end

