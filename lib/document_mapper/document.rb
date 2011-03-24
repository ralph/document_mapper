require 'active_model'

module DocumentMapper
  class Document
    include ActiveModel::AttributeMethods

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

    def read_yaml
      @content = File.read(file_path)

      if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @content = @content[($1.size + $2.size)..-1]
        self.attributes = YAML.load($1)
      end
      self.attributes ||= {}
      if !self.attributes.has_key? 'date'
        begin
          match = File.basename(@file_path).match(/(\d{4})-(\d{1,2})-(\d{1,2}).*/)
          self.attributes['date'] = Date.new(match[1].to_i, match[2].to_i, match[3].to_i)
        rescue NoMethodError => err
        end
      end
      self.class.define_attribute_methods self.attributes.keys
      self.attributes.keys.each { |attr| define_read_method attr }
    end

  private
    def define_read_method(attr_name)
      access_code = "attributes['#{attr_name}']"
      self.class.generated_attribute_methods.module_eval("def #{attr_name}; #{access_code}; end", __FILE__, __LINE__)
    end
  end
end
