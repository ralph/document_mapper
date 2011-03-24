require 'active_model'

module DocumentMapper
  class Document
    include ActiveModel::AttributeMethods
    include AttributeMethods::Read
    include YamlParsing

    attr_accessor :file_path, :attributes, :content

    def self.from_file(file_path)
      if !File.exist? file_path
        raise FileNotFoundException
      end
      self.new.tap do |document|
        document.file_path = file_path
        document.read_yaml
      end
    end

    def self.where(hash)
      Query.new(self).where(hash)
    end

    def self.sort(field)
      Query.new(self).sort(field)
    end

    def self.select(options = {})
    end

  end
end
