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
      module OID
        # :nodoc:
        #
        class TypeMapInitializer
          # :nodoc:
          #
          def register_enum_type(row)
            register row['oid'], ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Enum.new(name: row['typname'])
          end
        end
      end
    end
  end
end
