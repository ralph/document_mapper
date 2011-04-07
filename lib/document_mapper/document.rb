require 'active_model'
require 'forwardable'

module DocumentMapper
  class Document
    include ActiveModel::AttributeMethods
    include AttributeMethods::Read
    include YamlParsing

    extend Forwardable
    def_delegators :date, :year, :month, :day

    attr_accessor :file_path, :attributes, :content
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

    def self.where(hash)
      Query.new(self).where(hash)
    end

    def self.sort(field)
      Query.new(self).sort(field)
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
