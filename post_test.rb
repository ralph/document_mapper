require 'minitest/spec'
MiniTest::Unit.autorun
require 'set'
require 'fileutils'
require './post.rb'

describe Post do
  describe 'when finding all posts' do
    before do
      @posts = Post.all
    end

    it 'should return an Array' do
      assert_equal Array, @posts.class
    end
  
    it "should find all posts" do
      assert_equal 2, @posts.size
    end
  end

  describe 'when initializing a Post' do
    before do
      @post = Post.new('./posts/2010-08-08-test-post.textile')
    end

    it 'should initialize the content' do
      assert_equal "I like the flowers.\n", @post.content
    end

    it 'should intitialize strings from the front matter' do
      assert_equal String, @post.title.class
      assert_equal 'The shizzle!', @post.title
    end

    it 'should intitialize strings from the front matter' do
      assert_equal Array, @post.tags.class
      assert_equal ['tag'], @post.tags
    end

    it 'should intitialize integers from the front matter' do
      assert_equal Fixnum, @post.number_of_foos.class
      assert_equal 42, @post.number_of_foos
    end
  end

  describe 'when listing posts by an array attribute' do
    it 'should return a Hash' do
      assert_equal Hash, Post.by_tags.class
    end

    it 'should use the tags as Hash keys' do
      assert_equal Set.new(['tag', 'tug']), Post.by_tags.keys.to_set
    end

    it 'should use the posts as Hash values' do
      posts = Post.by_tags
      assert_equal Set.new([1, 2]), posts['tag'].map(&:id).to_set
      assert_equal Set.new([2]), posts['tug'].map(&:id).to_set
    end
  end

  describe 'when finding a post by an attribute' do
    it 'should find the right post' do
      title = 'The shizzle!'
      post = Post.find_by_title(title)
      assert_equal title, post.title
    end
  end

  describe 'when getting the file name or file path' do
    it 'should show the right file name' do
      post = Post.new './posts/2010-08-08-test-post.textile'
      file_name = '2010-08-08-test-post.textile'
      assert_equal file_name, post.file_name
    end

    it 'should show the right file path' do
      file_path = './posts/2010-08-08-test-post.textile'
      post = Post.new file_path
      assert_equal file_path, post.file_path
    end
  end

  describe 'when calling a method that was not defined dynamically' do
    it 'should throw an error on the class level' do
      assert_raises(NoMethodError) { Post.hululu }
    end

    it 'should throw an error on the instance level' do
      post = Post.new('./posts/2010-08-08-test-post.textile')
      assert_raises(NoMethodError) { post.hululu }
    end
  end

  describe 'when reloading all posts' do
    before do
      @default_dir = './posts'
      Post.posts_dir = @default_dir
      Post.reload!
      @posts_before = Post.all
      @tmp_dir = "#{@default_dir}-#{Time.now.to_i}-#{rand(999999)}-test"
      FileUtils.cp_r @default_dir, @tmp_dir
    end

    after do
      FileUtils.rm_r(@tmp_dir) if Dir.exist?(@tmp_dir)
    end

    it 'should get updated posts' do
      updated_post = <<-eos
---
id: 1
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the foos.
eos
      post_filename = "#{@tmp_dir}/2010-08-08-test-post.textile"
      File.open(post_filename, 'w') {|f| f.write(updated_post) }
      Post.posts_dir = @tmp_dir
      Post.reload!
      posts_after = Post.all

      assert_equal @posts_before.first.id, posts_after.first.id
      refute_equal @posts_before.first.title, posts_after.first.title
      refute_equal @posts_before.first.tags, posts_after.first.tags
      refute_equal @posts_before.first.number_of_foos, posts_after.first.number_of_foos
      refute_equal @posts_before.first.content, posts_after.first.content
    end

    it 'should get new posts' do
      new_post = <<-eos
---
id: 3
title: The shuzzle!
tags: [tig]
number_of_foos: 48
---

I like the cows.
eos
      post_filename = "#{@tmp_dir}/2010-08-15-new-test-post.textile"
      File.open(post_filename, 'w') {|f| f.write(new_post) }
      Post.posts_dir = @tmp_dir
      Post.reload!
      posts_after = Post.all

      assert_equal @posts_before.size + 1, posts_after.size
      assert_equal 'The shuzzle!', posts_after.last.title
      assert_equal "I like the cows.\n", posts_after.last.content
    end

    it 'should not change if no posts were changed' do
      Post.reload!
      posts_after = Post.all
      assert_equal @posts_before.map(&:id), posts_after.map(&:id)
    end

    it 'should not show deleted posts' do
      post_filename = "#{@tmp_dir}/2010-08-08-test-post.textile"
      FileUtils.rm post_filename
      Post.posts_dir = @tmp_dir
      Post.reload!
      posts_after = Post.all
      refute_equal @posts_before.map(&:id), posts_after.map(&:id)
    end
  end
end

