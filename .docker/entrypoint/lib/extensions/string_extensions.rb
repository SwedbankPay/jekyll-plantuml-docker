# frozen_string_literal: true

# Extend string to allow for bold text.
class String
  def safe_strip
    value = self.frozen? ? self.dup : self
    value.strip!
    value
  end
end
