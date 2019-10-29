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
        # You can change this behaviour by providing the enum type as an option under the `:name` key.
        #
        # @example Creating a user role.
        #   t.enum :role, name: :user_role
        #
        # @param name    [String] The name of the enum column.
        # @param options [Hash]   The options (including the name of the enum type).
        #
        def enum(name, options = {})
          column(name, options[:name] || name, options.except(:name))
        end
      end
    end
  end
end
