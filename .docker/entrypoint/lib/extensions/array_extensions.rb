# frozen_string_literal: true

# Array extensions
class Array
  def valid?
    !nil? && is_a?(Array) && !empty?
  end
end
