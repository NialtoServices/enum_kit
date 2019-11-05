# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module Enum
    # Retrieve the acceptable values for the enum type associated with the given column.
    #
    # @param  [String, Symbol] The name of an enum column.
    # @return [Array]          The acceptable values for the enum type associated with the column.
    #
    def pg_enum_values(column_name)
      type = columns_hash[column_name.to_s]&.sql_type

      raise "Unable to determine '#{table_name}.#{column_name}' type. Did you forget to db:migrate?" if type.blank?

      enums = connection.enums[type.to_sym]

      raise "Unable to retrieve enums for type '#{type}'. Did you forget to db:migrate?" if enums.nil?

      enums
    end

    # Define a PostgreSQL enum type.
    #
    # @param name    [String] The name of an enum column.
    # @param options [Hash]   The options.
    #
    def pg_enum(name, options = {})
      values = pg_enum_values(name).map { |value| [value.to_sym, value.to_s] }

      enum(name => Hash[values])

      enum = type_for_attribute(name)

      raise 'Expected an ActiveRecord::Enum::EnumType' unless enum.is_a?(ActiveRecord::Enum::EnumType)

      enum.disable_exceptions = options.key?(:exceptions) && !options[:exceptions]

      nil
    end
  end
end
