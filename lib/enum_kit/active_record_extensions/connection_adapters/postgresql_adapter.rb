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
          select_all(ENUM_QUERY.tr("\n", ' ').strip).each_with_object({}) do |row, enums|
            enums[row['typname'].to_sym] = row['values'].split("\t\t")
          end
        end

        # Create a new enum type in the database.
        #
        # @param name   [Symbol] The enum's name.
        # @param values [Array]  The enum's acceptable values.
        #
        def create_enum(name, values)
          name   = EnumKit.sanitize_name!(name)
          values = EnumKit.sanitize_values!(values)

          execute "CREATE TYPE #{name} AS ENUM #{EnumKit.sqlize(values)}"
        end

        # Rename an existing enum type.
        #
        # @param current_name [Symbol] The enum's current name.
        # @param new_name     [Symbol] The enum's new name.
        #
        def rename_enum(current_name, new_name)
          current_name = EnumKit.sanitize_name!(current_name)
          new_name     = EnumKit.sanitize_name!(new_name)

          execute "ALTER TYPE #{current_name} RENAME TO #{new_name}"
        end

        # Drop an existing enum type from the database.
        #
        # @param name [Symbol] The enum's name.
        #
        def drop_enum(name)
          name = EnumKit.sanitize_name!(name)

          execute "DROP TYPE #{name}"
        end

        # Add a new value to an enum type in the database.
        #
        # Note that you can't specify both :before and :after.
        #
        # @param name   [Symbol]        The enum's name.
        # @param value  [String|Symbol] The value to add.
        # @param after  [String|Symbol] An existing value after which the new value should be inserted.
        # @param before [String|Symbol] An existing value before which the new value should be inserted.
        #
        def add_enum_value(name, value, after: nil, before: nil)
          name  = EnumKit.sanitize_name!(name)
          value = EnumKit.sanitize_value!(value)

          statement = "ALTER TYPE #{name} ADD VALUE #{EnumKit.sqlize(value)}"

          raise ArgumentError, "You can't specify both :before and :after" if before && after

          statement += " AFTER #{EnumKit.sqlize(EnumKit.sanitize_value!(after))}"   if after
          statement += " BEFORE #{EnumKit.sqlize(EnumKit.sanitize_value!(before))}" if before

          execute(statement)
        end

        # Rename a value within an enum type in the database.
        #
        # @param name          [Symbol]        The enum's name.
        # @param current_value [String|Symbol] The enum value's current name.
        # @param new_value     [String|Symbol] The enum value's new name.
        #
        def rename_enum_value(name, current_name, new_name)
          ensure_renaming_enum_values_is_supported!

          name         = EnumKit.sanitize_name!(name)
          current_name = EnumKit.sanitize_value!(current_name)
          new_name     = EnumKit.sanitize_value!(new_name)

          execute "ALTER TYPE #{name} RENAME VALUE #{EnumKit.sqlize(current_name)} TO #{EnumKit.sqlize(new_name)}"
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

        # Raise an exception if the active PostgreSQL version doesn't support renaming enum values.
        #
        def ensure_renaming_enum_values_is_supported!
          return if ActiveRecord::Base.connection.postgresql_version >= 100_000

          raise NotImplementedError, 'PostgreSQL 10.0+ is required to enable renaming of enum values.'
        end
      end
    end
  end
end
