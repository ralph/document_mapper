require 'yaml'

class Post
  @@posts_dir = './posts'
  @@posts = nil
  attr_reader :content, :file_path

  def initialize(file_path)
    @file_path = file_path
    read_yaml
  end

  def file_name
    self.file_path.split('/').last
  end

  def self.all
    return @@posts if @@posts
    self.reload!
  end

  def self.reload!
    if File.directory?(@@posts_dir)
      file_paths = Dir.glob("#{@@posts_dir}/*.*")
      @@posts = file_paths.map { |file_path| Post.new File.join(Dir.getwd, file_path) }
    else
      []
    end
  end

  def self.posts_dir
    @@posts_dir
  end

  def self.posts_dir=(new_dir)
    @@posts_dir = new_dir
  end

private
  def read_yaml
    @content = File.read(@file_path)

    if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
      @content = @content[($1.size + $2.size)..-1]
      @data = YAML.load($1)
    end
    @data ||= {}
    define_dynamic_methods
  end

  def define_dynamic_methods
    @data.each do |method_name, value|
      value = "'#{value}'" if value.is_a? String
      instance_eval "def #{method_name}; #{value}; end"

      if value.is_a? Array
        by_attribute_method = <<-eos
          def self.by_#{method_name}
            posts = self.all
            #{method_name} = {}
            posts.each do |post|
              post.#{method_name}.each do |single_item|
                if #{method_name}.has_key? single_item
                  #{method_name}[single_item] << post
                else
                  #{method_name}[single_item] = [post]
                end
              end
            end
            #{method_name}
          end
        eos
        self.class.send(:module_eval, by_attribute_method)
      end

      find_by_attribute_method = <<-eos
        def self.find_by_#{method_name}(attribute)
          all.detect {|post| post.#{method_name} == attribute}
        end
        eos
      self.class.send(:module_eval, find_by_attribute_method)
    end
    @@dynamic_methods_defined = true
  end

  def self.method_missing(method_name, *args)
    self.all unless @@posts
    super
  end
end
