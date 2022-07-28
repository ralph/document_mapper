# frozen_string_literal: true

module DocumentMapper
  class Query
    def initialize(model)
      @model = model
      @where = {}
      @limit = nil
      @offset = nil
      @order_by = nil
    end

    def where(constraints_hash)
      selector_hash = constraints_hash.select { |key, _value| key.is_a? Selector }
      symbol_hash = constraints_hash.reject { |key, _value| key.is_a? Selector }
      symbol_hash.each do |attribute, value|
        selector = Selector.new(attribute: attribute, operator: 'equal')
        selector_hash.update({ selector => value })
      end
      @where.merge! selector_hash
      self
    end

    def order_by(field)
      @order_by = field.is_a?(Symbol) ? { field => :asc } : field
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
      all.first
    end

    def last
      all.last
    end

    def all
      result = @model.select(where: @where, order_by: @order_by)
      result = result.last([result.size - @offset, 0].max) if @offset.present?
      result = result.first(@limit) if @limit.present?
      result
    end
  end
end
