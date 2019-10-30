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
        class Enum < Type::Value
          # @return [String] The name of the PostgreSQL type representing the enum.
          #
          attr_reader :enum_type

          # :nodoc:
          #
          def initialize(options = {})
            @enum_type = options.delete(:enum_type).to_sym
            super
          end
        end
      end
    end
  end
end
