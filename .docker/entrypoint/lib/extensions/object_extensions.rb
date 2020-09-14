# frozen_string_literal: true

require_relative '../errors/file_not_found_error'
require_relative '../errors/directory_not_found_error'

# Object extensions
class Object
  def valid_array?
    !nil? && is_a?(Array) && !empty?
  end

  def must_be_a_directory!
    must_be_a! :non_empty, String

    dnfe = Jekyll::PlantUml::DirectoryNotFoundError
    raise dnfe, "#{self} does not exist" unless Dir.exist?(self)
  end

  def must_be_a_file!
    must_be_a! :non_empty, String

    fnfe = Jekyll::PlantUml::FileNotFoundError
    raise fnfe, "#{self} cannot be found." unless writable_file?
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

  def must_be_a!(*args)
    parsed_args = parse_args(*args)
    type = parsed_args[:type]
    specifier = parsed_args[:specifier]
    raise ArgumentError, 'Type cannot be nil' if type.nil?
    raise ArgumentError, "#{type} cannot be nil" if nil?
    raise ArgumentError, "#{self.class} is not a #{type}" unless is_a? type

    cannot_be_empty(self.class) if specifier == :non_empty && empty?
  end

  private

  def cannot_be_empty(_klass)
    raise ArgumentError, "#{self.class} cannot be empty"
  end

  def parse_args(*args)
    raise ArgumentError, 'args cannot be nil' if args.nil?

    case args.size
    when 1
      type = args[0]
    when 2
      specifier = args[0]
      type = args[1]
    else
      raise ArgumentError, '1 to 2 arguments required'
    end

    { specifier: specifier, type: type }
  end
end
