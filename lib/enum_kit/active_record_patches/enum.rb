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
    def pg_enum_values(name)
      # Determine the PostgreSQL type name for the enum.
      type = type_for_attribute(name)
      type = type.instance_eval { subtype } if type.is_a?(ActiveRecord::Enum::EnumType)

      # Query the PostgreSQL database for the enum's acceptable values.
      connection.enums[type.enum_type]
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
      enum.disable_exceptions = options.key?(:exceptions) && !options[:exceptions]

      nil
    end
  end
end
