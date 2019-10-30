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

        # Rename an existing enum type.
        #
        # @param current_name [Symbol] The current enum name.
        # @param new_name     [Symbol] The new enum name.
        #
        def rename_enum(current_name, new_name)
          current_name = EnumKit.sanitize_name!(current_name)
          new_name     = EnumKit.sanitize_name!(new_name)

          execute "ALTER TYPE #{current_name} RENAME TO #{new_name}"
        end

        # Drop an existing enum type from the database.
        #
        # @param name [Symbol] The name of the existing enum type.
        #
        def drop_enum(name)
          name = EnumKit.sanitize_name!(name)

          execute "DROP TYPE #{name}"
        end

        # :nodoc:
        #
        def migration_keys
          super + [:enum_type]
        end

        # :nodoc:
        #
        def prepare_column_options(column)
          spec = super
          spec[:enum_type] = column.sql_type.inspect if column.type == :enum
          spec
        end
      end
    end
  end
end
