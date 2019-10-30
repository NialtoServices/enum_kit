# frozen_string_literal: true

require 'enum_kit/active_record_extensions/connection_adapters/postgresql/schema_dumper'

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
        module ColumnDumper
          # :nodoc:
          #
          prepend EnumKit::ActiveRecordExtensions::ConnectionAdapters::PostgreSQL::SchemaDumper
        end
      end
    end
  end
end
