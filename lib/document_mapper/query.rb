module DocumentMapper
  class Query
    def initialize(model)
      @model = model
      @where = {}
    end

    def where(constraints_hash)
      differentiator = ->(key, value){ key.is_a? Selector }
      selector_hash = constraints_hash.select &differentiator
      symbol_hash = constraints_hash.reject &differentiator
      symbol_hash.each do |attribute, value|
        selector = Selector.new(:attribute => attribute, :operator => 'equal')
        selector_hash.update({ selector => value })
      end
      @where.merge! selector_hash
      self
    end

    def sort(field)
      @sort = field
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
      result = @model.select(:where => @where, :sort => @sort)
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
