module DocumentMapper
  class Query
    def initialize(model)
      @model = model
      @where = {}
    end

    def where(hash)
      @where.merge! hash
      self
    end

    def sort(field)
      @sort = field
      self
    end

    def first
      self.all.first
    end

    def last
      self.all.last
    end

    def all
      @model.select(:where => @where, :sort => @sort)
    end
  end
end
