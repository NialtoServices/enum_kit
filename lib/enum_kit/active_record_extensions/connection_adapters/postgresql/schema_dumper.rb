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
      module PostgreSQL
        # :nodoc:
        #
        module SchemaDumper
          # :nodoc:
          #
          def extensions(stream)
            enums(stream)
            super
          end

          # Write `create_enum` statements for each of the enum types created in the database to the specified stream.
          #
          # @param stream [IO] The stream to write the statements into.
          #
          def enums(stream)
            statements = @connection.enums.map do |name, values|
              "  create_enum #{name.inspect}, #{values.inspect}"
            end

            return if statements.empty?

            stream.puts statements.join("\n")
            stream.puts
          end

          # :nodoc:
          #
          def prepare_column_options(column)
            spec = super
            spec[:name] = column.sql_type.inspect if column.type == :enum
            spec
          end
        end
      end
    end
  end
end
