# frozen_string_literal: true

require 'date'

module DocumentMapper
  class YamlParsingError < StandardError; end

  module YamlParsing
    def read_yaml
      file_path = attributes[:file_path]
      @content = File.read(file_path)

      if @content =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)/m
        @content = @content[(Regexp.last_match(1).size + Regexp.last_match(2).size)..]
        attributes.update(yaml_load(Regexp.last_match(1), file_path).transform_keys(&:to_sym))
      end

      file_name = File.basename(file_path)
      extension = File.extname(file_path)
      attributes.update({
                          file_name: file_name,
                          extension: extension.sub(/^\./, ''),
                          file_name_without_extension: File.basename(file_path, extension)
                        })

      unless attributes.key? :date
        begin
          match = attributes[:file_name].match(/(\d{4})-(\d{1,2})-(\d{1,2}).*/)
          year = match[1].to_i
          month = match[2].to_i
          day = match[3].to_i
          attributes[:date] = ::Date.new(year, month, day)
        rescue NoMethodError
        end
      end

      if attributes.key? :date
        attributes[:year] = attributes[:date].year
        attributes[:month] = attributes[:date].month
        attributes[:day] = attributes[:date].day
      end

      self.class.define_attribute_methods attributes.keys
      attributes.each_key { |attr| self.class.define_read_method attr }
    end

    def yaml_load(yaml, file)
      YAML.load(yaml)
    rescue ArgumentError, Psych::SyntaxError
      raise YamlParsingError, "Unable to parse YAML of #{file}"
    end
  end
end
