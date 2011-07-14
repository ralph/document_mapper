module DocumentMapper
  class Query
    def initialize(model)
      @model = model
      @where = {}
    end

    def where(constraints_hash)
      selector_hash = constraints_hash.reject { |key, value| !key.is_a? Selector }
      symbol_hash = constraints_hash.reject { |key, value| key.is_a? Selector }
      symbol_hash.each do |attribute, value|
        selector = Selector.new(:attribute => attribute, :operator => 'equal')
        selector_hash.update({ selector => value })
      end
      @where.merge! selector_hash
      self
    end

    def order_by(field)
      @order_by = field.is_a?(Symbol) ? {field => :asc} : field
      self
    end

    def offset(number)
      @offset = number
      self
    end

    def limit(number)
      @limit = number
      self
    end

    def first
      self.all.first
    end

    def last
      self.all.last
    end

    def all
      result = @model.select(:where => @where, :order_by => @order_by)
      if @offset.present?
        result = result.last(result.size - @offset)
      end
      if @limit.present?
        result = result.first(@limit)
      end
      result
    end
  end
end
