require 'json'
require 'rexml/document'


# Parse properties file.
class Properties
  def initialize
    @properties = { }
  end

  # Setting the value of a property.
  #
  # @param key Property name.
  # @param value Value to set for the property.
  # @return [NilClass]
  def []=(key, value)
    set_property key, value
    nil?
  end

  # Getting the value of a property.
  #
  # @param key Property name.
  # @return [String]
  def [](key)
    get_property key
  end

  # Get an iterator object.
  #
  # @return [Array]
  def each
    items.each do |item|
      yield item
    end
  end

  # Convert the current object to string.
  #
  # @return [String]
  def to_s
    to_string
  end

  # Loads a property list(key and element pairs) from the .properties file.
  # The file is assumed to use the ISO-8859-1(Latin1) character encoding.
  #
  # @param file_name .properties file name.
  # @raise IOError When an error occurs while reading the file.
  # @raise ArgumentError When the file contains a malformed
  #                      Unicode escape sequence.
  # @return [void]
  def load(file_name)
    temp = File.read file_name, :encoding => "iso-8859-1"
    temp = temp.gsub /^[ \t]*[#!].*[\r\n\f]+/, ""
    temp = temp.gsub /(?<!\\)\\[ \t]*[\r\n\f]+[ \t]*/, ""
    raw_data = temp.split /[\r\n\f]+/
    raw_data.each do |i|
      pair = i.split /(?<!\\)[ \t]*(?<!\\)[=:][ \t]*/, 2
      if pair[0] != nil and pair[0].strip != ""
        key = load_convert pair[0], :is_convert_key => true
        if pair.length == 2
          value = load_convert pair[1]
          @properties[key] = value
        else
          @properties[key] = ""
        end
      end
    end
    nil?
  end

  # Saves a property list(key and element pairs) to the .properties file.
  # The file will be written in ISO-8859-1(Latin1) character encoding.
  #
  # @param file_name .properties file name.
  # @raise IOError When an error occurs while writing the file.
  # @return [NilClass]
  def save(file_name)
    file = File.open file_name, "w", :encoding => "iso-8859-1"
    @properties.each_pair do |k, v|
      key = save_convert k, :is_convert_key => true
      value = save_convert v
      pair = key + "=" + value
      file.write pair + "\n"
    end
    file.close
    nil?
  end

  # Loads a property list(key and element pairs) from the .xml file.
  #
  # The XML document will have the following DOCTYPE declaration:
  # <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
  #
  # @param file_name .xml file name.
  # @raise IOError When an error occurs while reading the file.
  # @raise ParseException When the XML file is malformed.
  # @return [NilClass]
  def load_from_xml(file_name)
    raw = File.read file_name, :encoding => "utf-8"
    doc = REXML::Document.new raw
    pairs = doc.root.elements
    pairs.each "entry" do |pair|
      if pair.attributes.key? "key"
        key = pair.attributes["key"]
        value = pair.text
        @properties[key] = value
      else
        raise ParseException "Malformed XML format."
      end
    end
  end

  # Saves a property list(key and element pairs) from the .xml file.
  #
  # The XML document will have the following DOCTYPE declaration:
  # <!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
  #
  # @param file_name .xml file name.
  # @raise IOError When an error occurs while writing the file.
  # @return [NilClass]
  def save_to_xml(file_name)
    xml_declaration = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    doctype = "<!DOCTYPE properties SYSTEM " +
      "\"http://java.sun.com/dtd/properties.dtd\">\n"
    root = REXML::Element.new "properties"
    @properties.each do |k, v|
      entry = REXML::Element.new "entry"
      entry.add_attribute "key", k
      entry.text = v
      root.add_element entry
    end
    file = File.open file_name, "w", :encoding => "utf-8"
    file.write xml_declaration
    file.write doctype
    doc = REXML::Document.new
    doc.add_element root
    doc.write file, 2, :encoding => "utf-8"
  end

  # Converts escape sequences to chars.
  #
  # @param value String to convert.
  # @param is_convert_key Whether to convert the key.
  # @raise ArgumentError When the file contains a malformed
  #                      Unicode escape sequence.
  # @return [String]
  def load_convert(value, is_convert_key = false)
    value = value.gsub /\\\\/, "\\"
    value = value.gsub /\\b/, "\b"
    value = value.gsub /\\t/, "\t"
    value = value.gsub /\\r/, "\r"
    value = value.gsub /\\n/, "\n"
    value = value.gsub /\\f/, "\f"
    if is_convert_key
      value = value.gsub /\\ /, " "
      value = value.gsub /\\=/, "="
      value = value.gsub /\\:/, ":"
    end
    escapes = value.scan(/\\u[A-F0-9]{4}/)
    escapes.each do |escape|
      temp = 0
      escape.chars[2..].each do |i|
        if "0123456789".include? i
          temp = (temp << 4) + i.ord - "0".ord
        elsif "abcdef".include? i
          temp = (temp << 4) + 10 + i.ord - "a".ord
        elsif "ABCDEF".include? i
          temp = (temp << 4) + 10 + i.ord - "A".ord
        else
          raise ArgumentError "Malformed \\uxxxx encoding."
        end
      end
      char = temp.chr "utf-8"
      value = value.gsub escape, char
    end
    value
  end
  private :load_convert

  # Converts chars to escape sequences.
  #
  # @param value String to convert.
  # @param is_convert_key Whether to convert the key.
  # @return [String]
  def save_convert(value, is_convert_key = false)
    buffer = []
    value = value.gsub /\\/, "\\\\"
    value = value.gsub /\b/, "\\b"
    value = value.gsub /\t/, "\\t"
    value = value.gsub /\r/, "\\r"
    value = value.gsub /\n/, "\\n"
    value = value.gsub /\f/, "\\f"
    if is_convert_key
      value = value.gsub /[ ]/, "\\ "
      value = value.gsub /[=]/, "\\="
      value = value.gsub /:/, "\\:"
    end
    value.chars.each do |char|
      if char.ord < 0x20 or char.ord > 0x7e
        char = "\\u" + "%04x" % char.ord
      end
      buffer.append char
    end
    buffer.join
  end
  private :save_convert

  # Setting the value of a property.
  #
  # @param key Property name.
  # @param value Value to set for the property.
  # @return [NilClass]
  def set_property(key, value)
    @properties[key] = value
  end

  # Getting the value of a property.
  #
  # @param key Property name.
  # @param default Default value if property does not exist.
  # @raise KeyError When property does not exist.
  # @return [String]
  def get_property(key, default = "")
    if not @properties.key? key and default != ""
      return default
    end
    @properties[key]
  end

  # Deleting the value of a property.
  #
  # @param key Property name.
  # @raise KeyError When property does not exist.
  # @return [NilClass]
  def delete_property(key)
    @properties.delete key
  end

  # Remove all properties
  #
  # @return [NilClass]
  def clear
    @properties.clear
  end

  # Getting the list of properties name.
  #
  # @return [Array]
  def keys
    @properties.keys
  end

  # Getting the list of properties value.
  #
  # @return [Array]
  def values
    @properties.values
  end

  # Getting the list of properties key-value pair.
  #
  # @return [Array]
  def items
    @properties.keys.zip @properties.values
  end

  # Get the number of properties.
  #
  # @return [Integer]
  def count
    @properties.count
  end

  # Returns a value whether the key exists.
  #
  # @return [Boolean]
  def contains?(key)
    @properties.key? key
  end

  # Returns a value whether two object instances are equal.
  #
  # @param other Other object to compare.
  # @return [Boolean]
  def equals?(other)
    self == other
  end

  # Convert the current object to string.
  #
  # @return [String]
  def to_string
    JSON.dump @properties
  end
end

