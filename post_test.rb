require 'minitest/spec'
MiniTest::Unit.autorun
require './post.rb'
require 'set'

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
      Post.all
      title = 'The shizzle!'
      post = Post.find_by_title(title)
      assert_equal title, post.title
    end
  end
end

