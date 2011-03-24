module DocumentMapper
  class Document

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

    def define_attribute_method(method_name)
      self.class.module_eval <<-STR, __FILE__, __LINE__ + 1
        if method_defined?(:#{method_name})
          undef :#{method_name}
        end
        def #{method_name}
          self.attributes['#{method_name}']
        end
      STR
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
      self.attributes.keys.each { |attr| define_attribute_method attr }
    end
  end
end
