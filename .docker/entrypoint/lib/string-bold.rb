# Extend string to allow for bold text.
class String
  def bold
    "\033[1m#{self}\033[0m"
  end
end
