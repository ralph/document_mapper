module DocumentMapper
  module YamlParsing
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
      self.attributes.keys.each { |attr| self.class.define_read_method attr }
    end
  end
end
