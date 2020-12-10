# frozen_string_literal: true

# Extend string to allow for bold text.
class String
  def safe_strip
    value = frozen? ? dup : self
    value.strip!
    value
  end
end
