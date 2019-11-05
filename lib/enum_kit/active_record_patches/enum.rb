# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module Enum
    # Retrieve the acceptable values for the enum type associated with the given column.
    #
    # @param  column_name [String, Symbol] The name of a column representing an enum.
    # @return             [Array]          The acceptable values for the enum type associated with the column.
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
    # By default, setting an enum attribute to an unregistered value results in an exception being raised.
    # You can disable this feature by setting the option `:exceptions` to `false` when registering the enum:
    #   => pg_enum :size, exceptions: false
    #
    # @param column_name [String, Symbol] The name of a column representing an enum.
    # @param options     [Hash]           Any additional options.
    #
    def pg_enum(column_name, options = {})
      values = pg_enum_values(column_name).map { |v| [v.to_sym, v.to_s] }

      enum(column_name => Hash[values])

      enum = type_for_attribute(column_name)

      raise 'Expected an ActiveRecord::Enum::EnumType' unless enum.is_a?(ActiveRecord::Enum::EnumType)

      enum.disable_exceptions = options.key?(:exceptions) && !options[:exceptions]

      nil
    end
  end
end
