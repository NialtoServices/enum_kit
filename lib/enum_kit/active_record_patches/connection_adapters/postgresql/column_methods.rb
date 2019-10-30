# frozen_string_literal: true

# :nodoc:
#
module ActiveRecord
  # :nodoc:
  #
  module ConnectionAdapters
    # :nodoc:
    #
    module PostgreSQL
      # :nodoc:
      #
      module ColumnMethods
        # Create an enum column with the provided name.
        #
        # By default, the enum type will match the name of the column.
        # You can change this behaviour by providing the enum type as an option under the `:enum_type` key.
        #
        # @example Creating a user role.
        #   t.enum :role, enum_type: :user_role
        #
        # @param enum_type [String] The name of the enum column.
        # @param options   [Hash]   The options (including the enum type).
        #
        def enum(name, options = {})
          column(name, options[:enum_type] || name, options.except(:enum_type))
        end
      end
    end
  end
end
