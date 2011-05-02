module DocumentMapper
  module YamlParsing
    def read_yaml
      file_path = self.attributes[:file_path]
      @content = File.read(file_path)

      if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @content = @content[($1.size + $2.size)..-1]
        self.attributes.update(YAML.load($1).symbolize_keys)
      end

      file_name = File.basename(file_path)
      extension = File.extname(file_path)
      self.attributes.update({
        :file_name => file_name,
        :extension => extension.sub(/^\./, ''),
        :file_name_without_extension => File.basename(file_path, extension)
      })

      if !self.attributes.has_key? :date
        begin
          match = attributes[:file_name].match(/(\d{4})-(\d{1,2})-(\d{1,2}).*/)
          year, month, day = match[1].to_i, match[2].to_i, match[3].to_i
          self.attributes[:date] = Date.new(year, month, day)
        rescue NoMethodError => err
        end
      end

      if self.attributes.has_key? :date
        self.attributes[:year] = self.attributes[:date].year
        self.attributes[:month] = self.attributes[:date].month
        self.attributes[:day] = self.attributes[:date].day
      end

      self.class.define_attribute_methods self.attributes.keys
      self.attributes.keys.each { |attr| self.class.define_read_method attr }
    end
  end
end
