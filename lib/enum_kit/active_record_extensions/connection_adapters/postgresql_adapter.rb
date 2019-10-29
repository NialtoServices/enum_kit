# frozen_string_literal: true

# :nodoc:
#
module EnumKit
  # :nodoc:
  #
  module ActiveRecordExtensions
    # :nodoc:
    #
    module ConnectionAdapters
      # :nodoc:
      #
      module PostgreSQLAdapter
        # @return [String] An SQL query that returns all available enum types in the database.
        #
        ENUM_QUERY = <<~SQL
          SELECT
          pg_type.OID,
          pg_type.typname,
          pg_type.typtype,
          array_to_string(array_agg(pg_enum.enumlabel ORDER BY pg_enum.enumsortorder), '\t\t', '') as values
          FROM pg_type
          LEFT JOIN pg_enum ON pg_enum.enumtypid = pg_type.oid
          WHERE pg_type.typtype = 'e'
          GROUP BY pg_type.OID, pg_type.typname, pg_type.typtype
          ORDER BY pg_type.typname
        SQL

        # @return [Hash] The enum types available in the database.
        #
        def enums
          @enums ||= select_all(ENUM_QUERY.tr("\n", ' ').strip).each_with_object({}) do |row, enums|
            enums[row['typname'].to_sym] = row['values'].split("\t\t")
          end
        end

        # Create a new enum type in the database.
        #
        # @param name   [Symbol] The name of the new enum type.
        # @param values [Array]  The enum's acceptable values.
        #
        def create_enum(name, values)
          name   = EnumKit.sanitize_name!(name)
          values = EnumKit.sanitize_values!(values)

          execute "CREATE TYPE #{name} AS ENUM #{EnumKit.sqlize(values)}"
        end

        # Drop an existing enum type from the database.
        #
        # @param name [Symbol] The name of the existing enum type.
        #
        def drop_enum(name)
          execute "DROP TYPE #{name}"
        end

        # :nodoc:
        #
        def migration_keys
          super + [:name]
        end

        # :nodoc:
        #
        def prepare_column_options(column, types)
          spec = super(column, types)
          spec[:name] = column.cast_type.type.inspect if column.type == :enum
          spec
        end
      end
    end
  end
end
