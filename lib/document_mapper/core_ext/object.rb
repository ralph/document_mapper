# frozen_string_literal: true

# Backported from ActiveSupport 3.1. Should be removed once the 3.1
# version is out.

class Object
  # Returns true if this object is included in the argument. Argument must be
  # any object which responds to +#include?+. Usage:
  #
  #   characters = ["Konata", "Kagami", "Tsukasa"]
  #   "Konata".in?(characters) # => true
  #
  # This will throw an ArgumentError if the argument doesn't respond
  # to +#include?+.
  def in?(another_object)
    another_object.include?(self)
  rescue NoMethodError
    raise ArgumentError, 'The parameter passed to #in? must respond to #include?'
  end
end
