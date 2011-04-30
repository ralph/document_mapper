class Symbol
  DocumentMapper::VALID_OPERATORS.each do |operator|
    class_eval <<-OPERATORS
      def #{operator}
        Selector.new(:attribute => self, :operator => '#{operator}')
      end
    OPERATORS
  end
end
