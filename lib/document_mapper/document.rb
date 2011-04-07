require 'active_model'
require 'forwardable'

module DocumentMapper
  class Document
    include ActiveModel::AttributeMethods
    include AttributeMethods::Read
    include YamlParsing

    extend Forwardable
    def_delegators :date, :year, :month, :day

    attr_accessor :attributes, :content, :directory, :file_path
    @@documents = []

    def self.reset
      @@documents = []
    end

    def self.from_file(file_path)
      if !File.exist? file_path
        raise FileNotFoundError
      end
      self.new.tap do |document|
        document.file_path = File.expand_path(file_path)
        document.read_yaml
        @@documents << document
      end
    end

    def self.directory=(new_directory)
      raise FileNotFoundError unless File.directory?(new_directory)
      self.reset
      @@directory = Dir.new File.expand_path(new_directory)
      @@directory.each do |file|
        next if ['.', '..'].include? file
        self.from_file [@@directory.path, file].join('/')
      end
    end

    def self.where(hash)
      Query.new(self).where(hash)
    end

    def self.sort(field)
      Query.new(self).sort(field)
    end

    def self.offset(number)
      Query.new(self).offset(number)
    end

    def self.limit(number)
      Query.new(self).limit(number)
    end

    def self.select(options = {})
      documents = @@documents.dup
      options[:where].each do |attribute, value|
        documents.select! do |document|
          document.send(attribute) == value
        end
      end
      documents
    end

    def self.all
      @@documents
    end

    def ==(other_document)
      return false unless other_document.is_a? Document
      self.file_path == other_document.file_path
    end
  end
end
