require './test/test_base'

describe MyDocument do
  describe 'when finding all document_files' do
    before do
      @document_files = MyDocument.all
    end

    it 'should return a DocumentFile::Collection' do
      assert_equal DocumentFile::Collection, @document_files.class
    end
  
    it "should find all document_files" do
      assert_equal 2, @document_files.size
    end
  end

  describe 'when initializing a MyDocument' do
    before do
      @document_file = MyDocument.new('2010-08-08-test-document-file.textile')
    end

    it 'should know the documents_dir' do
      assert_equal MyDocument.documents_dir, @document_file.documents_dir
    end

    it 'should initialize the content' do
      assert_equal "I like the flowers.\n", @document_file.content
    end

    it 'should intitialize Strings from the front matter' do
      assert_equal String, @document_file.title.class
      assert_equal 'The shizzle!', @document_file.title
    end

    it 'should intitialize Arrays from the front matter' do
      assert_equal Array, @document_file.tags.class
      assert_equal ['tag'], @document_file.tags
    end

    it 'should intitialize integers from the front matter' do
      assert_equal Fixnum, @document_file.number_of_foos.class
      assert_equal 42, @document_file.number_of_foos
    end

    it 'should work with absolute path' do
      document_file = MyDocument.new(
        TEST_DIR + '/documents/2010-08-08-test-document-file.textile'
      )
      assert_equal MyDocument, document_file.class
    end
  end

  describe 'when initializing the date' do
    after do
      remove_document @file_name if @file_name
    end

    it 'should initialize the date from the filename' do
      document_file = MyDocument.new '2010-08-08-test-document-file.textile'
      assert_equal Date.new(2010, 8, 8), document_file.date
    end

    it 'should initialize the date from the YAML front matter' do
      @file_name = 'date-test-1.textile'
      add_document @file_name, <<-eos
---
id: 5
title: Date test 1
date: 2010-09-10
---

I like the dates.
eos
      document_file = MyDocument.new @file_name
      assert_equal Date.new(2010, 9, 10), document_file.date
    end

    it 'should prefer the date from the YAML front matter' do
      @file_name = '2010-08-15-date-test-1.textile'
      add_document @file_name, <<-eos
---
id: 5
title: Date test 2
date: 2010-08-20
---

I like the dates.
eos
      document_file = MyDocument.new @file_name
      assert_equal Date.new(2010, 8, 20), document_file.date
    end

    it 'should not set a date if neither filename nor YAML date is set' do
      @file_name = 'date-test-1.textile'
      add_document @file_name, <<-eos
---
id: 5
title: Date test 3
---

I like the dates.
eos
      document_file = MyDocument.new @file_name
      assert_nil document_file.date
    end
  end

  describe 'when getting the file name or file path' do
    before do
      @file_name = '2010-08-08-test-document-file.textile'
    end

    it 'should show the right file name' do
      document_file = MyDocument.new @file_name
      file_name = '2010-08-08-test-document-file'
      assert_equal file_name, document_file.file_name
    end

    it 'should show the right file name with extension' do
      document_file = MyDocument.new @file_name
      file_name = '2010-08-08-test-document-file.textile'
      assert_equal file_name, document_file.file_name_with_extension
    end

    it 'should show the right extension' do
      document_file = MyDocument.new @file_name
      extension = '.textile'
      assert_equal extension, document_file.file_extension
    end

    it 'should show the right file path' do
      document_file = MyDocument.new @file_name
      expected_path = [MyDocument.documents_dir, @file_name].join('/')
      assert_equal expected_path, document_file.file_path
    end
  end

  describe 'when calling a method that was not defined dynamically' do
    it 'should throw an error on the class level' do
      assert_raises(NoMethodError) { MyDocument.hululu }
    end

    it 'should throw an error on the instance level' do
      file_path = './test/documents/2010-08-08-test-document-file.textile'
      document_file = MyDocument.new file_path
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
      MyDocument.documents_dir = @tmp_dir
    end

    after do
      FileUtils.rm_r(@tmp_dir) if Dir.exist?(@tmp_dir)
    end

    it 'should get updated document_files' do
      add_document '2010-08-08-test-document-file.textile', <<-eos
---
id: 1
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the foos.
eos
      MyDocument.reload!
      document_files_after = MyDocument.all

      assert_equal @document_files_before.first.id, document_files_after.first.id
      refute_equal @document_files_before.first.title, document_files_after.first.title
      refute_equal @document_files_before.first.tags, document_files_after.first.tags
      refute_equal @document_files_before.first.number_of_foos, document_files_after.first.number_of_foos
      refute_equal @document_files_before.first.content, document_files_after.first.content
    end

    it 'should get new document_files' do
      add_document '2010-08-15-new-test-document_file.textile', <<-eos
---
id: 3
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the cows.
eos
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
      remove_document '2010-08-08-test-document-file.textile' # has id 1
      MyDocument.reload!
      document_files_after = MyDocument.all
      refute document_files_after.map(&:id).include? 1
    end
  end

  def add_document(file_name, content)
    complete_file_name = [MyDocument.documents_dir, file_name].join('/')
    File.open(complete_file_name, 'w') {|f| f.write(content) }
  end

  def remove_document(file_name)
    complete_file_name = [MyDocument.documents_dir, file_name].join('/')
    FileUtils.rm complete_file_name if File.exist? complete_file_name
  end
end

