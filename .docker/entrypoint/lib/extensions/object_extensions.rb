# frozen_string_literal: true

# Object extensions
class Object
  def must_be_a_directory!
    raise ArgumentError, 'Value cannot be nil' if nil?

    must_be_a! String

    raise ArgumentError, 'String cannot be empty' if empty?
    raise Jekyll::PlantUml::DirectoryNotFoundError, "#{self} does not exist" unless Dir.exist?(self)
  end

  def must_be_a_file!
    raise ArgumentError, 'Value cannot be nil' if nil?

    must_be_a! String

    raise ArgumentError, 'String cannot be empty' if empty?
    raise Jekyll::PlantUml::FileNotFoundError, "#{self} cannot be found." unless writable_file?
  end

  def writable_file?
    return true if File.writable? self

    false
  end

  def value_for(key)
    must_be_a! Hash
    raise ArgumentError, 'Hash cannot be empty' if empty?
    raise ArgumentError, "No '#{key}' key found in the hash" unless key? key

    self[key]
  end

  def must_be_a!(type)
    raise ArgumentError, 'Value cannot be nil' if nil?
    raise ArgumentError, "#{self.class} is not a #{type}" unless is_a? type
  end
end
