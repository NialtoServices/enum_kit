# frozen_string_literal: true

module EnumKit
  # Makes an underscored, lowercase form from the expression in the string.
  #
  # Changes '::' to '/' to convert namespaces to paths.
  # This method is based on the `ActiveSupport::Inflector.underscore` method.
  #
  # @param  value [String] A value to transform.
  # @return       [String] The underscored, lowercase form of the expression.
  #
  def self.underscore(value)
    return value unless /[A-Z-]|::/.match?(value)

    value = value.to_s.gsub('::', '/')
    value.gsub!('PostgreSQL', 'Postgresql')
    value.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    value.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    value.tr!('-', '_')
    value.downcase!
    value
  end

  # Convert a value into a String that can be used in SQL.
  #
  # @param  value [Array|String|Symbol] A value to convert into SQL format.
  # @return       [String]              The SQL representation of the value.
  #
  def self.sqlize(value)
    case value
    when Array
      '(' + value.map { |v| sqlize(v) }.join(', ') + ')'
    when String
      ActiveRecord::Base.connection.quote(value)
    when Symbol
      sqlize(value.to_s)
    else
      raise ArgumentError, "Unable to convert value of type #{value.class} into SQL format."
    end
  end

  # Sanitize the name of the enum.
  #
  # @param  name [String|Symbol] An enum name.
  # @return      [String]        The sanitized name.
  #
  def self.sanitize_name!(name)
    raise ArgumentError, 'Enum names must be a String or a Symbol.' unless name.is_a?(String) || name.is_a?(Symbol)

    name = name.to_s

    return name if name =~ /^[a-z0-9_]+$/

    raise ArgumentError, 'Enum names may contain only lowercase letters, numbers and underscores.'
  end

  # Sanitize a single value of an enum.
  #
  # @param  value [String|Symbol] An enum value.
  # @return       [Array]         The sanitized value.
  #
  def self.sanitize_value!(value)
    raise ArgumentError, 'Enum values must be a String or a Symbol.' unless value.is_a?(String) || value.is_a?(Symbol)

    value = value.to_s

    return value if value =~ /^[a-z0-9_ ]+$/

    raise ArgumentError, 'Enum values may contain only lowercase letters, numbers, underscores and spaces.'
  end

  # Sanitize the values of an enum.
  #
  # @param  values [Array] An Array of String or Symbol values.
  # @return        [Array] A sanitized Array of String values.
  #
  def self.sanitize_values!(values)
    return nil if values.nil?

    raise ArgumentError, 'Enum values must be an Array of String and/or Symbol objects.' unless values.is_a?(Array)

    values.map { |value| sanitize_value!(value) }
  end
end
