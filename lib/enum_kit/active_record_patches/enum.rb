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
    # @param column_name [String, Symbol] The name of a column representing an enum.
    #
    def pg_enum(column_name)
      values = pg_enum_values(column_name).map { |v| [v.to_sym, v.to_s] }
      enum(column_name => Hash[values])
    end
  end
end
