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
